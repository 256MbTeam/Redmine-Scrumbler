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

class ScrumblerProjectSettingTest < ActiveSupport::TestCase
  fixtures :projects,
    :issue_statuses,
    :trackers,
    :projects_trackers

  def setup
    @project = projects(:projects_001)
    @project_setting = ScrumblerProjectSetting.new(:project => @project)
    @project_setting.save
  end
  
  test "should associate with project" do
    assert_equal @project.name, @project_setting.project.name
  end
  
  test "should create settings" do
    assert_instance_of(HashWithIndifferentAccess, @project_setting.settings)
  end
  
  test "should create trackers settings" do
    assert_equal @project.trackers.count, @project_setting.trackers.count
  end
  
  test "should find tracker settings" do
    tracker = @project.trackers.first
    tracker_setting = @project_setting.find_tracker(tracker.id)
    assert_equal tracker.id, tracker_setting[:id]
    assert_equal tracker.position, tracker_setting[:position]
    assert_equal ScrumblerProjectSetting::DEFAULT_COLOR_MAP[(tracker.id % ScrumblerProjectSetting::DEFAULT_COLOR_MAP.size)], tracker_setting[:color]
    assert tracker_setting[:use]
  end
  
  test "should create issue status settings" do
    assert_equal IssueStatus.count, @project_setting.issue_statuses.count
  end
  
  test "should find issue status" do
    issue_status = IssueStatus.first
    issue_status_setting = @project_setting.find_issue_status(issue_status.id)
    assert_equal issue_status.id, issue_status_setting[:id]
    assert_equal issue_status.position, issue_status_setting[:position]
    assert issue_status_setting[:use]
  end
  
  test "should not save without project" do
    @project_setting = ScrumblerProjectSetting.new
    assert !@project_setting.save
  end
  
  test "should create setting after assign tracker for project" do
    @project = projects(:projects_003)
    @project_setting = ScrumblerProjectSetting.new(:project => @project)
    @project_setting.save
    @tracker = trackers(:trackers_001)
    @project.trackers << @tracker
    assert ScrumblerProjectSetting.find(@project_setting.id).find_tracker(@tracker.id)
    
    assert_equal @tracker.id, ScrumblerProjectSetting.find(@project_setting.id).find_tracker(@tracker.id)[:id]
    assert ScrumblerProjectSetting.find(@project_setting.id).trackers[@tracker.id]
  end
  
end
