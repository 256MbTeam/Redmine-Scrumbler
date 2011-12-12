require File.dirname(__FILE__) + '/../test_helper'

class ScrumblerProjectSettingTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :issue_statuses

  test "should not save without project" do
    project_setting = ScrumblerProjectSetting.new
    assert !project_setting.save
  end
  
  test "should associate with project" do
    project_setting = ScrumblerProjectSetting.new(:project => projects(:projects_001))
    project_setting.save
    assert_equal projects(:projects_001).name, project_setting.project.name
  end
  
  test "should create settings" do
    project_setting = ScrumblerProjectSetting.new(:project => projects(:projects_001))
    project_setting.save
    assert_not_nil project_setting.settings
    assert_instance_of(HashWithIndifferentAccess, project_setting.settings)
  end
  
  test "should create trackers settings" do
    project_setting = ScrumblerProjectSetting.new(:project => projects(:projects_001))
    project_setting.save
    assert_equal projects(:projects_001).trackers.count, project_setting.trackers.count
  end

  test "should create issue status settings" do
    project_setting = ScrumblerProjectSetting.new(:project => projects(:projects_001))
    project_setting.save
    assert_equal IssueStatus.count, project_setting.issue_statuses.count
  end
  
end
