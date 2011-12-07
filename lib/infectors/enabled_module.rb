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
  module Infectors
    module EnabledModule
      module ClassMethods;end

      module InstanceMethods
        def enable_module
          if self.name == Scrumbler::MODULE_NAME
            unless self.project.scrumbler_project_setting
              self.project.create_scrumbler_project_setting
              ScrumblerIssueCustomField.points.projects << self.project
            end
            self.project.create_scrumbler_sprints
          end
        end
        
        def disable_module
          if self.name == Scrumbler::MODULE_NAME
            self.project.scrumbler_sprints.destroy_all
            self.project.scrumbler_project_setting.try(:destroy)
            ScrumblerIssueCustomField.points.projects.delete(self.project)
          end
        end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          after_create :enable_module
          before_destroy :disable_module
        }
      end
    end
  end
end

