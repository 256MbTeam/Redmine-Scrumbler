
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

module ScrumblerSprintsHelper

  def scrumbler_sprint_settings_tabs
    [
      {:name => 'general', :action => :update_general, :partial => 'general', :label => :label_general},
      {:name => 'trackers', :action => :update_trackers, :partial => 'trackers', :label => :label_tracker_plural},
      {:name => 'issue_statuses', :action => :update_issue_statuses, :partial => 'issue_statuses', :label => :label_issue_statuses},
    ]
  end
end
