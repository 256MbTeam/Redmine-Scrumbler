# Scrumbler - Add scrum functionality to any Redmine installation
# Copyright (C) 2011 256Mb Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
module ScrumblerHelper
  def scrumbler_javascript_helper
    # This Hack fir compability with  "Redmine - Stuff To Do Plugin".
    # That guys transform array to hash in this place.
    prepare_stupid_hash = Proc.new {|name|
      data = t(name)
      data = data.values if data.is_a?(Hash)
      data
    }

    translations = {
      :scrumbler_sprint => t(:scrumbler_sprint),
      :nodata => t(:label_no_data),
      :label_backlog => t(:label_backlog),
      :label_new_sprint => t(:label_new_sprint),
      :issue_not_assigned => t(:issue_not_assigned),
      :scrumbler_statistics => t(:scrumbler_statistics),
      :label_header_error  => t(:label_header_error),
      :label_confirm_sprint_opening => t(:label_confirm_sprint_opening),
      :highstock => {
        :months => prepare_stupid_hash.call("date.month_names").compact,
        :shortMonths => prepare_stupid_hash.call("date.abbr_month_names").compact,
        :weekdays => prepare_stupid_hash.call("date.day_names").compact
      }
    }
    javascript_tag "var Scrumbler = {}; Scrumbler.Translations = #{translations.to_json}; Scrumbler.root_url = #{root_url.to_json}; Scrumbler.possible_points = #{ScrumblerIssueCustomField.points.possible_values.to_json};"
  end

  def prepare_issue_subject(issue)
    subj = issue.subject
    if issue.children?
      subj << "<hr>"
      issue.children.each {|child|
        link = "<a href=\"#{url_for({:controller => 'issues', :action => 'show', :id => child.id})}\" class=\"#{child.css_classes}\" title=\"#{child.subject[0..99]} (#{child.status.name})\">##{child.tracker.name} #{child.id}</a>"

        # link_to("##{child.tracker.name} #{child.id}", url_for({:controller => 'issues', :action => 'show', :id => child.id}),
        # :class => child.css_classes,
        # :title => "#{child.subject[0..99]} (#{child.status.name})")
        subj << "#{link}: #{child.subject} <br>"
      }
    end
    subj
  end

  def select_color_tag(name, value=nil, options={})
    out = hidden_field_tag(name, value, options)
    out << javascript_tag("new TinyColorChooser(\"#{sanitize_to_id(name)}\", #{options.to_json})");
  end

  def issue_for_json(issue)
    out = {
      :id => issue.id,
      :status_id => issue.status_id,
      :tracker_id => issue.tracker_id,
      :project_id => issue.project_id,
      :subject => prepare_issue_subject(issue),
      :points => issue.scrumbler_points,
      :closed => issue.closed?
    }
    out[:assigned_to] = {:id   => issue.assigned_to_id, :name => issue.assigned_to.name } if issue.assigned_to

    out
  end
  



  def prepare_issue_statuses(issue_statuses_settings, issue_statuses)
    r_issue_statuses = {}
    issue_statuses_settings.each{|id,issue_setting|
      _status = issue_statuses.detect {|status| status.id == id.to_i}
      r_issue_statuses[id.to_i] = issue_setting.merge({
        :status_id => id.to_i,
        :closed =>  _status.try(:is_closed),
        :name => _status.try(:name)
      })
    }
    r_issue_statuses
  end

  def prepare_trackers(trackers_settings, trackers)
    r_trackers = {}
    trackers_settings.each{|id,tracker_setting|
      r_trackers[id.to_i]=tracker_setting.merge({:name => trackers.detect {|tracker| tracker.id == id.to_i}.try(:name)})
    }
    r_trackers
  end

  def draw_scrumbler_dashboard(sprint)
    div_id = "dashboard_for_sprint_#{sprint.id}"
    prepared_issues = sprint.issues.sort(){|a,b| sprint.trackers[a.tracker_id.to_s][:position].to_i <=> sprint.trackers[b.tracker_id.to_s][:position].to_i }.map {|issue| issue_for_json(issue) }
    config = {
      :sprint => sprint,
      :name => sprint.name,
      :project => sprint.project,
      :statuses => prepare_issue_statuses(sprint.issue_statuses, IssueStatus.all),
      :trackers => prepare_trackers(sprint.trackers, sprint.project.trackers),
      :issues => prepared_issues,
      :url => project_url(sprint.project),
      :current_user_id => User.current.id
    }.to_json
    out = content_tag('div', '&nbsp;', {:style => "width:100%; height: 100%;"})
    out = "<div id='#{div_id}' style='width:100%;height:100%;'>&nbsp;</div>"
    out << javascript_tag("new Scrumbler.ScrumblerDashboard('#{div_id}', #{config});")
  end

  def select_sprint_statuses_tag(name, selected)
    select_tag name, options_for_select(ScrumblerSprint::STATUSES.collect {|s| [l("scrumbler_sprint_#{s}"), s]}, selected)
  end
end
