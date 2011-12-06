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
    module Tracker
      module ClassMethods;end

      module InstanceMethods
        private
        def add_self_to_scrumbler_points
          ScrumblerIssueCustomField.points.trackers << self
        end
        
        def remove_self_from_scrumbler_points
          ScrumblerIssueCustomField.points.trackers.delete(self)
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          after_create :add_self_to_scrumbler_points
          before_destroy :remove_self_from_scrumbler_points
        }
      end
    end
  end
end