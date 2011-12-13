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
