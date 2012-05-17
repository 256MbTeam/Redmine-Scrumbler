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
require 'sqlite_3_serialization_hack'
require 'redmine'
require 'dispatcher'

require_dependency "scrumbler"

Dispatcher.to_prepare Scrumbler::MODULE_NAME do
  require_dependency "scrumbler_infector"
end

Redmine::Plugin.register Scrumbler::MODULE_NAME do
  name 'Redmine Scrumbler plugin'
  url 'https://github.com/256MbTeam/Redmine-Scrumbler/'
  author 'Alexandr_Andrianov, Ivan Kotenko'
  description 'This is a scrum plugin for Redmine'
  version '1.5.0'
  project_module :redmine_scrumbler do
    permission :scrumbler, :scrumbler => [:index, :sprint], :public => true
    permission :scrumbler_backlog, :scrumbler_backlogs => [:show, :select_sprint, :create_version, :update_scrum_points, :change_issue_version, :open_sprint, :move_issue_priority],
               :public => true
    permission :scrumbler_settings, :scrumbler_settings => [:show, :update_trackers, :update_issue_statuses, :update_sprints],
                                    :scrumbler_sprints => [:settings, :update_general, :update_trackers, :update_issue_statuses],
                                    :public => true
  end

  menu :project_menu, :redmine_scrumbler, { :controller => 'scrumbler', :action => "index" }, :caption => :scrumbler_menu, :after => :activity, :param => :project_id
  menu :admin_menu, :redmine_scrumbler, {:controller => 'scrumbler_admins', :action => "index"}, :caption => :scrumbler_menu, :html => { :class => 'icon icon-scrumbler-burndown' }
end
