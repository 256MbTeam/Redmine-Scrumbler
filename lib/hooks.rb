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

module Scrumbler
  class Hooks < Redmine::Hook::ViewListener
    
    def create_version(params)
      @version = params[:version]
      @version.create_scrumbler_sprint(:project => @version.project)
    end
    
    def enable_module(params)
      @module = params[:module]
      @project = params[:project]
      if @module.name == Scrumbler::MODULE_NAME
        @project.create_scrumbler_project_setting(:maintrackers => @project.trackers.map(&:id))
        @project.create_scrumbler_sprints
      end
    end
    
    def disable_module(params)
      @module = params[:module]
      @project = params[:project]
      if @module.name == Scrumbler::MODULE_NAME
        @project.scrumbler_sprints.destroy_all
      end
    end
  end
end