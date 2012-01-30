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
module ScrumblerBacklogsHelper
  
   def prepare_issues_for_json(issues)

    issues.sort_by(&:priority).reverse.map{|issue|
      { :id => issue.id,
        :subject => issue.subject,
        :tracker_id => issue.tracker_id,
        :points => issue.scrumbler_points,
        # :tracker_name => 
      }
    }
  end

  def prepare_trackers(trackers_settings, trackers)
    trackers_settings.map{|tracker_id, settings|
      {
        :id => tracker_id,
        :name => trackers.detect {|tracker| tracker.id == tracker_id.to_i}.try(:name),
        :color => settings[:color]
      }
    }
  end

  def scrumbler_sprints_tabs(sprints)
    sprints_data = []
    sprints.each do |sprint|
      sprints_data << {
        :id => sprint.id,
        :name => sprint.name,
        :action => :update_general, :partial => 'sprint',
        :label => sprint.name,
        :trackers => prepare_trackers(sprint.trackers, @project.trackers),
        :issues => prepare_issues_for_json(sprint.issues)
      }
    end
    sprints_data
  end

  def sprint_issues(sprint)
    js_params = {
      :project_id => @project.identifier,
      :sprint_id => sprint[:id],
      :issues => sprint[:issues],
      :trackers => sprint[:trackers],
      :parent_id => "sprint_#{sprint[:id]}",
      :url => "/projects/#{@project.identifier}/scrumbler_backlogs/change_issue_version"
    }
    javascript_tag("new IssuesList(#{js_params.to_json})")
  end

  def backlog_issues
    js_params = {
      :project_id => @project.identifier,
      :issues => prepare_issues_for_json(@project.issues.without_version),
      :trackers => prepare_trackers(@project.scrumbler_project_setting.trackers, @project.trackers),
      :parent_id => "backlog_list",
      :url => "/projects/#{@project.identifier}/scrumbler_backlogs/change_issue_version"
    }
    javascript_tag("var backlog = new BacklogIssuesList(#{js_params.to_json})")
  end

  def render_sprint_tabs(sprints)
    if sprints.any?
      render :partial => 'sprints', :locals => {:sprints => sprints}
    else
      content_tag 'p', l(:label_no_data), :class => "nodata"
    end
  end
end
