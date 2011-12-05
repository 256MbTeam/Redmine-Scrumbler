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

class ScrumblerProjectSetting < ActiveRecord::Base
  
  #  Default colors, uses for color_chooser
  DEFAULT_COLOR_MAP = %w(faf faa afa aaf ffa aff)
  
  unloadable
  belongs_to :project
  
  serialize :settings, Hash
    
  def find_tracker(id)
    self.settings[:trackers][id.to_s] || {}
  end
  
  def find_issue_status(id)
    self.settings[:issue_statuses][id.to_s] || {}
  end
  
  #    create default settings for dashboard
  def after_initialize
    self.settings ||= {}
  
    if !self.settings[:issue_statuses] || self.settings[:issue_statuses].empty?
      self.settings[:issue_statuses] = {}

      IssueStatus.all.each {|status|
        self.settings[:issue_statuses][status.id] = {:id=>status.id,
          :use => true, 
          :position => status.position}
      }
    end 
    
    if !self.settings[:trackers] || self.settings[:trackers].empty?
      self.settings[:trackers] = {}
      self.project.trackers.each {|tracker|
        self.settings[:trackers][tracker.id] = {:id=>tracker.id,
          :use => true, 
          :position => tracker.position, 
          :color => DEFAULT_COLOR_MAP[(tracker.id % DEFAULT_COLOR_MAP.size)]}
      }
    end
  end
  
  private
  def put_default_statuses_if_not_exist
    
  end
  
 
end
