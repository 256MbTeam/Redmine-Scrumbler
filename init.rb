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

require 'redmine'
require 'dispatcher'

require_dependency "scrumbler"

Dispatcher.to_prepare :redmine_scrumbler do
  require_dependency "infector"
end

Redmine::Plugin.register :redmine_scrumbler do
  name 'Redmine Scrumbler plugin'
  url 'https://github.com/256MbTeam/Redmine-Scrumbler/'
  author 'Alexandr_Andrianov, Ivan Kotenko'
  description 'This is a scrum plugin for Redmine'
  version '1.3.1'
  project_module :redmine_scrumbler do
    permission :scrumbler, :scrumbler => :index, :public => true
    permission :scrumbler_settings, :scrumbler_settings => [:show, :update_trackers, :update_issue_statuses, :update_sprints], 
                                    :scrumbler_sprints => [:settings, :update_general, :update_trackers, :update_issue_statuses], 
                                    :public => true
  end
  
  menu :project_menu, :redmine_scrumbler, { :controller => 'scrumbler', :action => "index" }, :caption => :scrumbler_menu, :after => :activity, :param => :project_id
  
end
