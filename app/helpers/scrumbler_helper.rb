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

  def backlog_issue_filter_link
    link_to "backlog", 
      :controller => :issues, 
      :action => :index, 
      :project_id => @project,
      :f => %w(status_id fixed_version_id),
      :v => {
        :status_id => %W(5 6)
      },
      :op => {
        :fixed_version_id => "!*", 
        :status_id => "!"
        },
      :group_by => :priority,
      :set_filter => 1,
      :c => [:status, :priority, :subject, "cf_#{ScrumblerIssueCustomField.points.id}"]
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
      :subject => issue.subject
    }
    out[:assigned_to] = {:id   => issue.assigned_to_id, :name => issue.assigned_to.name } if issue.assigned_to
      
    out
  end
  
  def prepare_issue_statuses(issue_statuses_settings, issue_statuses)
    r_issue_statuses = {}
    issue_statuses_settings.each{|id,issue_setting|
      r_issue_statuses[id.to_i] = issue_setting.merge({:name => issue_statuses.detect {|status| status.id == id.to_i}.try(:name)})
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
    prepared_issues = sprint.issues.map {|issue| issue_for_json(issue) }
    #    prepared_issues_statuses = sprint.issue_statuses.map{|issue_status| issue_status_for_json(issue_status)}
    config = {
      :sprint => sprint,
      :project => sprint.project,
      #      :statuses => sprint.scrumbler_sprint_statuses,
      #      :trackers => Hash[*sprint.scrumbler_sprint_trackers.map{|t| [t.tracker_id,t]}.flatten],
      :statuses => prepare_issue_statuses(sprint.issue_statuses, IssueStatus.all),
      :trackers => prepare_trackers(sprint.trackers, sprint.project.trackers),
      :issues => prepared_issues,
      :url => project_url(sprint.project),
      :current_user_id => User.current.id
    }.to_json
    out = "<div id='#{div_id}'></div>"
    out << javascript_tag("new ScrumblerDashboard('#{div_id}', #{config})")
  end
  
end
