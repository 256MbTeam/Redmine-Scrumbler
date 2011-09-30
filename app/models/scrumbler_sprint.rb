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
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
  

  delegate :name, :to => :version
  
  class << self
    def create_if_not_exists(project_id, version_id)
      sprint_hash = {:project_id => project_id, :version_id => version_id}
      unless exists?(sprint_hash)
        create(sprint_hash)
      end
    end
  

    def create_sprints_for_project(project_id)
      @versions = Version.find(:all, :conditions => {:project_id => project_id})
      @versions.each do |version|
        create_if_not_exists(project_id, version.id)
      end
    end
  
    def destroy_if_exists(project_id, version_id)
      destroy_all(:project_id => project_id, :version_id => version_id)
    end

    def destroy_all_in_project(project_id)
      destroy_all(:project_id => project_id)
    end
  end

end
