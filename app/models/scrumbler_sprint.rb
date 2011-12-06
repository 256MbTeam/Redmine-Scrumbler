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
  belongs_to :version
  
  delegate :scrumbler_project_setting, :to => :project
  
  serialize :settings, Hash
  
#TODO PRIORITY
has_many :issues, :finder_sql => %q(select issues.* from scrumbler_sprints
inner join projects on scrumbler_sprints.project_id = projects.id
inner join issues on issues.project_id = projects.id
where issues.tracker_id in (#{self.trackers.keys.join(',')})
and issues.status_id in (#{self.issue_statuses.keys.join(',')})
and scrumbler_sprints.version_id = issues.fixed_version_id
and scrumbler_sprints.id = #{self.id}),:readonly => true, :uniq => true, :include => :assigned_to 
  
  
  def before_create
    self.settings ||={}
  end
  
  def trackers
    self.settings[:trackers] || scrumbler_project_setting.settings[:trackers]
  end 
  
  def issue_statuses
    self.settings[:issue_statuses] || scrumbler_project_setting.settings[:issue_statuses]
  end
  
  #  has_and_belongs_to_many :trackers, :join_table  => :scrumbler_sprint_trackers

  #  def after_create
  #    scrumbler_project_setting.settings[:trackers].each {|tracker_id, tracker|
  #      if(tracker[:use])
  #        self.scrumbler_sprint_trackers.create(:tracker_id => tracker_id, :color => 'FF0000')
  #      end
  #    }
  #    scrumbler_project_setting.settings[:issue_statuses].each {|issue_status_id, issue_status|
  #      self.scrumbler_sprint_statuses.create(:issue_status_id => issue_status_id)
  #    }
  #  end
end
