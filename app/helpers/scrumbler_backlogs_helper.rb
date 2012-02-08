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
  def prepare_issues_for_json(issues, trackers)
    issues.sort_by(&:priority).reverse.map{|issue|
      { :id => issue.id,
        :subject => issue.subject,
        :points => issue.scrumbler_points,
        :tracker => trackers.detect{|tracker| tracker[:id].to_s == issue.tracker_id.to_s}
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

  def prepare_sprint_for_json(project, sprint)
    trackers = prepare_trackers(sprint.trackers, project.trackers)
    {
      :id => sprint.id,
      :issues => prepare_issues_for_json(sprint.issues,trackers),
      :trackers => trackers,
      :url => "projects/#{project.identifier}/scrumbler_backlogs/change_issue_version"
    }
  end

  def prepare_backlog_for_json(project)
    trackers = prepare_trackers(project.scrumbler_project_setting.trackers, project.trackers)
    {
      :trackers => trackers,
      :issues => prepare_issues_for_json(project.issues.without_version, trackers),
      :url => "projects/#{project.identifier}/scrumbler_backlogs/change_issue_version"
    }
  end

  def prepare_backlogs_data_to_json(project)
    {
      :project_id => project.id,
      :backlog => prepare_backlog_for_json(project),
      :sprint => prepare_sprint_for_json(project, project.scrumbler_sprints.planning.first),
      :sprints => project.scrumbler_sprints.planning.map{|sprint| {:name => sprint.name, :id => sprint.id} }
    }
  end

  def backlog_issues
    javascript_tag("$('content').appendChild(new Scrumbler.Backlog(#{prepare_backlogs_data_to_json(@project).to_json}).el);")
  end

end
