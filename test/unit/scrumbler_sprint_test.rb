require File.dirname(__FILE__) + '/../test_helper'

class ScrumblerSprintTest < ActiveSupport::TestCase
  fixtures :scrumbler_project_settings

  def setup
    @sprint = ScrumblerSprint.new(:project => projects(:projects_001))
    @project_setting.save
  end
  
  def test_truth
#    puts scrumbler_project_settings(:project_settings_001).settings.inspect;
    assert true
  end
end
