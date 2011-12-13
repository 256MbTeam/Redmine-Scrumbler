require File.dirname(__FILE__) + '/../test_helper'

class ScrumblerSprintTest < ActiveSupport::TestCase
  fixtures :scrumbler_project_settings
  fixtures :projects
  fixtures :versions

  def setup
    @sprint = ScrumblerSprint.new(:project => projects(:projects_001), :version => versions(:versions_001))
    @sprint.save
  end

  test "should not save without project or version" do
    @sprint = ScrumblerSprint.new()
    assert !@sprint.save
    @sprint = ScrumblerSprint.new(:project => projects(:projects_001))
    assert !@sprint.save
    @sprint = ScrumblerSprint.new(:version => versions(:versions_001))
    assert !@sprint.save
  end

  test "should return scrumbler project settings if own setting undefined" do
    @scrumbler_project_setting = scrumbler_project_settings(:project_settings_001)
    assert_equal @scrumbler_project_setting.trackers, @sprint.trackers
    assert_equal @scrumbler_project_setting.issue_statuses, @sprint.issue_statuses
  end

end
