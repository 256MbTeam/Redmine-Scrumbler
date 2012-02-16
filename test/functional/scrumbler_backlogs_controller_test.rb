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

class ScrumblerBacklogsControllerTest < ActionController::TestCase
  fixtures :projects,
    :versions,
    :scrumbler_project_settings,
    :users,
    :roles,
    :members,
    :member_roles,
    :trackers,
    :projects_trackers,
    :enabled_modules,
    :enumerations,
    :issues
    
  def setup
    #    Infect project with scrumbler module
    @project = projects(:projects_001)
    enable_module_for(@project)

    #    Infect manager role with scrumbler permission
    @manager_role = roles(:roles_001)
    assign_permissions(@manager_role)

    #    user with manager role
    @manager = users(:users_002)
    #    user without permissions
    @user = users(:users_003)
    User.current = nil
  end

  test "Should not show backlog for permitted user" do
     post(:show, {:project_id => @project.id}, {:user_id => @user.id})
     assert_response 403 
  end

  test "Should show backlog for permitted user" do
     post(:show, {:project_id => @project.id}, {:user_id => @manager.id})
     assert_response :success 
  end
  

  test "Should update scrum points" do
    @issue = issues(:issues_001)
    post(:update_scrum_points, {:project_id => @project.id, :issue_id => @issue.id, :points => "10"}, {:user_id => @manager.id})
    
    assert_response :success
    
    # TODO Саня не получается тест, давай помоги    
    # assert_equal "10", Issue.find(@issue.id).scrumbler_points
  end
  

  test "should move issue to sprint from backlog" do
    version = Version.find(3)
    issue = issues(:issues_001)
    post(:change_issue_version, {:project_id => @project.id, :issue_id => issue.id, :sprint_id => version.scrumbler_sprint.id}, {:user_id => @manager.id})
    assert_response :success
    assert_equal version.id, Issue.find(1).fixed_version_id
  end

  test "should move issue to backlog from sprint" do
    post(:change_issue_version, {:project_id => @project.id, :issue_id => 2}, {:user_id => @manager.id})
    assert_response :success
    assert_nil Issue.find(2).fixed_version_id
  end
end
