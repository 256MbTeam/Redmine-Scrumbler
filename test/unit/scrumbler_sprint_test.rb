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

class ScrumblerSprintTest < ActiveSupport::TestCase
  fixtures :scrumbler_project_settings,
    :projects,
    :versions,
    :trackers,
    :projects_trackers,
    :issues,
    :issue_statuses

  def setup
    @project = projects(:projects_001)
    @version = versions(:versions_001)
    @scrumbler_project_setting = scrumbler_project_settings(:project_settings_001)
    @sprint = ScrumblerSprint.new(:project => @project, :version => @version)
    @sprint.save
  end

  test "should save with default status" do
    assert_equal "planning", @sprint.status
  end
  
  test "should save with status" do
    sprint = ScrumblerSprint.new(:project => @project, :version => @version, :status=>"opened")
    assert_equal "opened", sprint.status
  end
  
    
  test "should not save with incorrect status" do
    sprint = ScrumblerSprint.new(:project => @project, :version => @version, :status=>"abirabir")
    assert !sprint.save
  end
  
  
  test "Shuold not remove tracker from settings, if issues exists in this tracker" do
    @sprint.settings[:trackers] = {
      "2" => {"position"=>1, "id"=>1, "color"=>"faa", "use"=>true}
    }
    assert !@sprint.save
  end

  test "should return scrumbler project settings if own setting undefined" do
    assert_equal @sprint.trackers, @scrumbler_project_setting.trackers
    assert_equal @sprint.issue_statuses, @scrumbler_project_setting.issue_statuses
  end

end
