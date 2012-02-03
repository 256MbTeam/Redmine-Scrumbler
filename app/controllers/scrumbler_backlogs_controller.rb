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
class ScrumblerBacklogsController < ScrumblerAbstractController
  unloadable
  
  helper :scrumbler_backlogs
  include ScrumblerBacklogsHelper
  
  def index
    @selected_sprint = @project.scrumbler_sprints.planning.first
  end

  def update_scrum_points
    @issue = Issue.find(params[:issue_id])
    value = @issue.custom_value_for(ScrumblerIssueCustomField.points) || 
        ScrumblerIssueCustomField.points.custom_values.create(:customized => @issue)
    
    value.value = params[:points].to_s
    
    render :json => { :success => value.save,
                      :text => @issue.errors.full_messages.join(", <br>")
                    }
  end

  def change_issue_version
    @issue = Issue.find(params[:issue_id])
  
    @sprint = ScrumblerSprint.find_by_version_id(@issue.fixed_version_id)
    if @sprint #  Move from sprint to backlog
      @issue.fixed_version_id = nil
    else # Move from backlog to sprint
      @sprint = ScrumblerSprint.find(params[:sprint_id])
      @issue.fixed_version_id = @sprint.version_id
    end

    render :json => { :success => @issue.save,
                      :backlog => {:proejct_id => @project.identifier,
                                   :issues => prepare_issues_for_json(@project.issues.without_version),
                                   :trackers => prepare_trackers(@project.scrumbler_project_setting.trackers, @project.trackers)
                                  },
                      :sprint => {:proejct_id => @project.identifier,
                                  :issues => prepare_issues_for_json(@sprint.issues),
                                  :trackers => prepare_trackers(@sprint.trackers, @project.trackers)
                                 },
                      :text => @issue.errors.full_messages.join(", <br>")
                    }
  end
end
