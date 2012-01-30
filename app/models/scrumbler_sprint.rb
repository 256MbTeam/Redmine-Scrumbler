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

class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  STATUSES = ["opened", "planning", "closed"]
  validates_inclusion_of :status, :in => ScrumblerSprint::STATUSES
    
  default_scope :joins => [:version], :select => "#{ScrumblerSprint.table_name}.*, name"
  
  named_scope :opened, :conditions => {:status => "opened"}
  
  named_scope :planning, :conditions => {:status => "planning"}
  
  belongs_to :project
  validates_presence_of :project
  
  belongs_to :version
  validates_presence_of :version
  
  
  delegate :scrumbler_project_setting, :to => :project
  
  serialize :settings, HashWithIndifferentAccess
  
  validate :scrumbler_project_setting_validation
  validate :closing_validation
  validate :remove_tracker_validation
  
  
  has_many :issues, :readonly => true, :uniq => true, :include => [:assigned_to, :statuses],
    :finder_sql => %q(select issues.* from scrumbler_sprints
inner join projects on scrumbler_sprints.project_id = projects.id
inner join issues on issues.project_id = projects.id
where issues.tracker_id in (#{(self.trackers.keys << 0).join(',')})
and issues.status_id in (#{(self.issue_statuses.keys<< 0).join(',')})
and scrumbler_sprints.version_id = issues.fixed_version_id
and scrumbler_sprints.id = #{self.id})
  
  
  def points_total
    connection.select_value("select sum(value) from custom_values where 
custom_values.custom_field_id = #{ScrumblerIssueCustomField.points.id} and
custom_values.customized_type = 'Issue' and
custom_values.customized_id in (#{(self.issues.map(&:id) << 0).join(",")}) and
custom_values.value <> '#{ScrumblerIssueCustomField.points.default_value}'", :total_points).to_f
  end
  
  def points_completed
    connection.select_value("select sum(value) from custom_values where 
custom_values.custom_field_id = #{ScrumblerIssueCustomField.points.id} and
custom_values.customized_type = 'Issue' and
custom_values.customized_id in (select issues.id from scrumbler_sprints
inner join projects on scrumbler_sprints.project_id = projects.id
inner join issues on issues.project_id = projects.id
inner join issue_statuses on issue_statuses.id = issues.status_id 
where issues.tracker_id in (#{(self.trackers.keys << 0).join(',')})
and issues.status_id in (#{(self.issue_statuses.keys << 0).join(',')})
and issue_statuses.is_closed = true
and scrumbler_sprints.version_id = issues.fixed_version_id
and scrumbler_sprints.id = #{self.id}) and
custom_values.value <> '#{ScrumblerIssueCustomField.points.default_value}'", :completed_points).to_f
  end
  
  def name_with_points
    "#{name} (#{points_completed}/#{points_total})"
  end
  
  def after_initialize
    self.status ||= "planning"
    self.settings ||= HashWithIndifferentAccess.new
  end
  
  def trackers
    self.settings[:trackers] || scrumbler_project_setting.try(:trackers)
  end 
  
  def issue_statuses
    self.settings[:issue_statuses] || scrumbler_project_setting.try(:issue_statuses)
  end
  
  private
  
  def scrumbler_project_setting_validation
    if !project || !scrumbler_project_setting
#       TODO change error
      errors.add_to_base(:closing_sprint_with_opened_issues) 
    end
  end
  
  def closing_validation
    if Issue.open.exists?(:id => self.issues.map(&:id)) && self.status == "closed"
      errors.add_to_base(:closing_sprint_with_opened_issues) 
    end
  end
  
  def remove_tracker_validation
    if Issue.exists?(["tracker_id not in (?) and fixed_version_id = ?", self.trackers.keys, self.version_id])
         errors.add_to_base(:trackers_with_issues_in_sprint_cant_be_removed) 
    end
  end
  
end
