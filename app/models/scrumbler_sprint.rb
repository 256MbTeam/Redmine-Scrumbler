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
  
  default_scope :include => [:version]
  
  belongs_to :project
  belongs_to :version
  
  delegate :scrumbler_project_setting, :to => :project
  
  has_many :scrumbler_sprint_trackers, :dependent => :destroy
  has_many :scrumbler_sprint_statuses, :dependent => :destroy
  
  delegate :name, :to => :version
  
  has_and_belongs_to_many :trackers, :join_table  => :scrumbler_sprint_trackers
  
  def after_create
    scrumbler_project_setting.maintrackers.each {|tracker_id|
      self.scrumbler_sprint_trackers.create(:tracker_id => tracker_id)
    }
    scrumbler_project_setting.settings[:issue_statuses].each {|issue_status_id|
      self.scrumbler_sprint_statuses.create(:issue_status_id => issue_status_id)
    }
  end
end
