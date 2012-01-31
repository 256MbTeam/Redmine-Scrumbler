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
    module Issue
      module ClassMethods;end
      
      module InstanceMethods
        
        def scrumbler_points
          ScrumblerIssueCustomField.points.find_value_by_issue(self).try(:value) || 
            ScrumblerIssueCustomField.points.default_value
        end
        
        private
        def validate_sprint_trackers
          if @sprint = self.fixed_version.try(:scrumbler_sprint)
              tracker_setting = @sprint.trackers[self.tracker_id.to_s] || @sprint.trackers[self.tracker_id.to_i] 
              errors.add_to_base(:tracker_error) if !tracker_setting || !tracker_setting[:use]
            end
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          validate :validate_sprint_trackers
        }
      end
    end
  end
end