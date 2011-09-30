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
    def destroy_version(params)
      @version = params[:version]
      ScrumblerSprint.destroy_if_exists(@version.project_id, @version.id)
    end
    
    def create_version(params)
      @version = params[:version]
      ScrumblerSprint.create_if_not_exists(@version.project_id, @version.id)
    end
    
    def enable_module(params)
      @module = params[:module]
      if @module.name == Scrumbler::MODULE_NAME
        ScrumblerSprint.create_sprints_for_project(@module.project_id)
      end
    end
    
    def disable_module(params)
      @module = params[:module]
      if @module.name == Scrumbler::MODULE_NAME
        ScrumblerSprint.destroy_all_in_project(@module.project_id)
      end
    end
  end
end