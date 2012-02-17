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
    :scrumbler_issues,
    :issues,
    :issue_statuses

  set_fixture_class :scrumbler_issues => Issue
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

  test "should delegate end_date to version effective_date" do
    assert_equal @version.effective_date, @sprint.end_date
  end

  test "should save with status" do
    sprint = ScrumblerSprint.new(:project => @project, :version => @version, :status=>"opened")
    assert_equal "opened", sprint.status
  end

  test "should not save with incorrect status" do
    sprint = ScrumblerSprint.new(:project => @project, :version => @version, :status=>"abirabir")
    assert_equal false, sprint.valid?
  end

  test "If sprint have opened issues, sprint cant close and give the error" do
    @sprint.status = "closed"
    assert_equal false, @sprint.valid?
  end

  test "Shuold not remove tracker from settings, if issues exists in this tracker" do
    @sprint.settings[:trackers] = {
      "2" => {"position"=>1, "id"=>1, "color"=>"faa", "use"=>true}
    }
    assert_equal false, @sprint.valid?
  end

  test 'issue only can saved when status is planning' do
    sprint = ScrumblerSprint.create(:version => versions(:versions_003), :project => @project)

    issue = scrumbler_issues(:issue_without_version)
    issue.fixed_version_id = sprint.version_id

    assert_equal true, issue.valid?
  end

  test "cant assign task to sprint, if it not planning" do
    # This issue needed for opened sprint creation
    Issue.create(:author_id => 2, 
                 :subject => 'test', 
                 :tracker => Tracker.first, 
                 :fixed_version => versions(:versions_003), 
                 :project => @project)
 
    ScrumblerSprint.create(:status => "opened", 
                           :version => versions(:versions_003), 
                           :project => @project)

    issue = scrumbler_issues(:issue_without_version)
    issue.fixed_version_id = versions(:versions_003)

    assert_equal false, issue.valid?
  end

  test "Should be only one opened sprint in project" do
      opened_sprint     = ScrumblerSprint.create(:project => @project, :version => versions(:versions_001), :status=>"opened")
      planning_sprint   = ScrumblerSprint.create(:project => @project, :version => versions(:versions_003), :status=>"planning")
      
      planning_sprint.status = "opened"
      
      assert_equal false, planning_sprint.valid?
  end

  test "should return scrumbler project settings if own setting undefined" do
    assert_equal @sprint.trackers, @scrumbler_project_setting.trackers
    assert_equal @sprint.issue_statuses, @scrumbler_project_setting.issue_statuses
  end

  test "should not edit issues in closed sprint" do
    version = versions(:versions_003)

    issue = Issue.find(:first, :conditions => {:project_id => @project.id, :fixed_version_id => nil})
    issue.fixed_version_id = version.id
    issue.status = issue_statuses(:issue_statuses_005)
   
    safe_points = HashWithIndifferentAccess.new({
          "custom_field_values" => {
            ScrumblerIssueCustomField.points.id.to_s => "?"
          }
        })
    issue.safe_attributes = safe_points
    issue.save_issue_with_child_records(safe_points)
    assert_equal true, issue.valid?


    sprint = ScrumblerSprint.create(:version_id => version.id, :project_id => @project.id)
    sprint.status = "closed"
    sprint.save

    issue = Issue.find(:first, :conditions => {:fixed_version_id => version.id})
    issue.status = issue_statuses(:issue_statuses_001)


    assert_equal false, issue.valid?
    assert issue.errors[:base].include?(I18n.t("activerecord.errors.models.issue.attributes.base.sprint_is_closed_error"))
  end
  
  test "should not save sprint when start_date more then end_date" do
    version = versions(:versions_003)
    sprint = ScrumblerSprint.create(:version_id => version.id, 
                                    :project_id => @project.id, 
                                    :start_date => 1.days.ago.to_date,
                                    :end_date => 3.days.ago.to_date)
     
    assert sprint.errors[:base].include?(I18n.t("activerecord.errors.models.scrumbler_sprint.attributes.base.start_date_is_greater_than_end_date")) 
                
    assert_equal false, sprint.valid?
  end

end
