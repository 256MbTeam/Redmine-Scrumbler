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
        
        def get_prioroty
          # issue.custom_value_for(ScrumblerIssueCustomField.priority).try(:value).to_i
          ScrumblerIssueCustomField.priority.find_value_by_issue(self).try(:value).to_i || 0 
        end
        
        private

        def validate_sprint
          return unless (@sprint = fixed_version.try(:scrumbler_sprint)) && !parent_issue_id

          # Should not assign issue from disabled tracker
          tracker_setting = @sprint.trackers[self.tracker_id.to_s] || @sprint.trackers[self.tracker_id.to_i]
          errors[:base] << (:tracker_error) if !tracker_setting || !tracker_setting[:use]

          # should not add issue to not planning sprint
          if fixed_version_id_changed? && @sprint.status != ScrumblerSprint::PLANNING
            errors[:base] << (:sprint_not_planning_error)
          end

          # should not edit issues in closed sprint
          errors[:base] << (:sprint_is_closed_error) if @sprint.status == "closed"

          # should not add issue to limited sprint by points
          points = custom_value_for(ScrumblerIssueCustomField.points).try(:value).to_f

          if @sprint.max_points != 0 &&
          (@sprint.points_total + points - scrumbler_points.to_f) > @sprint.max_points
            errors[:base] << (:sprint_points_limit_error)
          end

        end
      end

      def self.included(receiver)
        receiver.module_eval {
          alias_method :available_custom_fields_without_points, :available_custom_fields
          def available_custom_fields
            if ScrumblerIssueCustomField.points.projects.include? self.project
              (available_custom_fields_without_points + [ScrumblerIssueCustomField.points]).uniq
            else
              available_custom_fields_without_points
            end
          end
        }
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          validate :validate_sprint
          scope :without_version, :where => {:fixed_version_id => nil}
        }
        
      end
    end
  end
end
