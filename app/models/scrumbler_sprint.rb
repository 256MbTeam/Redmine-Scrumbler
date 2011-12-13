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
  
  default_scope :joins => [:version], :select => "#{ScrumblerSprint.table_name}.*, status, name"
  
  named_scope :opened, :conditions => ["status = ?", "open"]
  
  belongs_to :project
  validates_presence_of :project
  
  belongs_to :version
  validates_presence_of :version
  
  delegate :scrumbler_project_setting, :to => :project
  
  serialize :settings, HashWithIndifferentAccess
  
  
  has_many :issues, :readonly => true, :uniq => true, :include => :assigned_to,
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
custom_values.value <> '#{ScrumblerIssueCustomField.points.default_value}'").to_f
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
custom_values.value <> '#{ScrumblerIssueCustomField.points.default_value}'").to_f
  end
  
  def name_with_points
   "#{name} (#{points_completed}/#{points_total})"
  end
  
  def before_create
    self.settings ||= HashWithIndifferentAccess.new
  end
  
  def trackers
    self.settings[:trackers] || scrumbler_project_setting.trackers
  end 
  
  def issue_statuses
    self.settings[:issue_statuses] || scrumbler_project_setting.issue_statuses
  end
  
end
