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

require File.dirname(__FILE__) + '/../test_helper'

class ScrumblerSprintsControllerTest < ActionController::TestCase
  fixtures :projects,
    :versions,
    :scrumbler_project_settings,
    :users,
    :roles,
    :members,
    :member_roles,
    :trackers,
    :projects_trackers,
    :enabled_modules
  
  def setup
    #    Infect project with scrumbler module
    @project = projects(:projects_001)
    enable_module_for(@project)
    
    #    Infect manager role with scrumbler permission
    @manager_role = roles(:roles_001)
    assign_permissions(@manager_role)
    
    #    user with manager role
    @manager = users(:users_002)
    @scrumbler_sprint = @project.versions.first.scrumbler_sprint
    User.current = nil
  end
  
  test "should update sprint trackers by admin" do 
    tracker_setting = {
      "1" => {"position"=>1, "id"=>1, "color"=>"faa", "enabled"=>true},
      "2" => {"position"=>3, "id"=>2, "color"=>"faa", "enabled"=>true},
      "3" => {"position"=>2, "id"=>3, "color"=>"faa", "enabled"=>true}
    }
    
    post(:update_trackers, {:project_id => @project.id, :id => @scrumbler_sprint.id, :scrumbler_sprint => {:scrumbler_sprint_trackers => tracker_setting}}, {:user_id => @manager.id})  
    assert_redirected_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :trackers)
    assert_equal "Successful update.", flash[:notice]
    assert_equal tracker_setting, ScrumblerSprint.find(@scrumbler_sprint.id).trackers
  end
  
  
  test "should update sprint issue statuses by admin" do 
    issue_statuses_setting = {
      "1" => {"position"=>3, "id"=>1, "enabled"=>true},
      "2" => {"position"=>1, "id"=>2, "enabled"=>true},
      "3" => {"position"=>2, "id"=>3, "enabled"=>true}
    }
    post(:update_issue_statuses, {:project_id => @project.id, :id => @scrumbler_sprint.id, :scrumbler_issue_statuses => issue_statuses_setting}, {:user_id => @manager.id})  
    assert_redirected_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :issue_statuses)
    assert_equal "Successful update.", flash[:notice]
    assert_equal issue_statuses_setting, ScrumblerSprint.find(@scrumbler_sprint.id).issue_statuses
  end
end
