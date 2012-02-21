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
  
  # def create_tracker_setting(tracker)
    # settings = ScrumblerProjectSetting.create_setting(tracker, false)
    # {
      # :id => tracker.id,
      # :name => tracker.name,
      # :color => settings[:color]
    # }
  # end
  
  def prepare_issues_for_json(issues, trackers)
    issues.sort_by(&:priority).reverse.map{|issue|
    
      { :id => issue.id,
        :subject => prepare_issue_subject(issue),
        :points => issue.scrumbler_points,
        :tracker => trackers.detect{|tracker| tracker[:id].to_s == issue.tracker_id.to_s} 
        # || create_tracker_setting(Tracker.find(issue.tracker_id))
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
  
  def prepare_all_trackers(trackers_settings, trackers)
    trackers.map{|tracker|
      {
        :id => tracker.id,
        :name => tracker.name,
        :color => (trackers_settings[tracker.id.to_s] || ScrumblerProjectSetting.create_setting(tracker,false))[:color]
      }
    }
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
    trackers = prepare_all_trackers(project.scrumbler_project_setting.trackers, project.trackers)
    issues = project.issues.open.without_version.all(:conditions => {:parent_id => nil})
    {
      :trackers => trackers,
      :issues => prepare_issues_for_json(issues, trackers)
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
