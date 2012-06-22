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
  def by_priority(issues)
    issues.sort {|a,b|
      v1 = a.try(:custom_value_for, ScrumblerIssueCustomField.priority).try(:value).to_i
      v2 = b.try(:custom_value_for, ScrumblerIssueCustomField.priority).try(:value).to_i
      v1==v2 ? b.priority <=> a.priority : v2 <=> v1 

    }
  end

  def prepare_issues_for_json(issues, trackers)
    by_priority(issues).map{|issue|
      { :id => issue.id,
        :subject => prepare_issue_subject(issue),
        :points => issue.scrumbler_points,
        :tracker => trackers.detect{|tracker| tracker[:id].to_s == issue.tracker_id.to_s}
      }
    }
  end

  def prepare_trackers(trackers_settings, trackers)
    if trackers_settings.nil?
      {}
    else
      trackers_settings.map{|tracker_id, settings|
        {
          :id => tracker_id,
          :name => trackers.detect {|tracker| tracker.id == tracker_id.to_i}.try(:name),
          :color => settings[:color]
        }
      }
    end
  end

  def prepare_all_trackers(trackers_settings, trackers)
    if trackers_settings.nil?
      trackers.map{|tracker|
        {
          :id => tracker.id,
          :name => tracker.name,
          :color => (ScrumblerProjectSetting.create_setting(tracker,false))[:color]
        }
      }
    else
      trackers.map{|tracker|
        {
          :id => tracker.id,
          :name => tracker.name,
          :color => (trackers_settings[tracker.id.to_s] || ScrumblerProjectSetting.create_setting(tracker,false))[:color]
        }
      }
    end
  end

  def prepare_sprint_for_json(sprint)
    return {:issues=>[],:trackers=>[]} unless sprint
    trackers = prepare_trackers(sprint.trackers, sprint.project.trackers)
    {
      :id => sprint.id,
      :issues => prepare_issues_for_json(sprint.issues, trackers),
      :trackers => trackers,
      :max_points => sprint.max_points
    }
  end

  def prepare_sprints(sprints)
    sprints.map{|sprint| {:name => sprint.name, :id => sprint.id} }
  end

  def prepare_backlog_for_json(project)
    all_trackers = prepare_all_trackers(project.scrumbler_project_setting.trackers, project.trackers)
    trackers = prepare_trackers(project.scrumbler_project_setting.trackers, project.trackers)
    issues =  Issue.open.all(:conditions => {:parent_id => nil,:fixed_version_id => nil, :project_id => project.id }, :include=>:custom_values)
    {
      :trackers => trackers,
      :issues => prepare_issues_for_json(issues, all_trackers)
    }
  end

  def prepare_backlogs_data_to_json(project)
    {
      :project_id => project.identifier,
      :backlog => prepare_backlog_for_json(project),
      :sprint => prepare_sprint_for_json(project.scrumbler_sprints.planning.first),
      :sprints => prepare_sprints(project.scrumbler_sprints.planning)
    }
  end

  def backlog_issues
    javascript_tag("$('content').appendChild(new Scrumbler.Backlog(#{prepare_backlogs_data_to_json(@project).to_json}).el);")
  end

end
