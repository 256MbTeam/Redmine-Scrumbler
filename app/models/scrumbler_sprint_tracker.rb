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

class ScrumblerSprintTracker < ActiveRecord::Base
  unloadable
  
  class << self
    def has_setting attr_name, args = {}
      self.send :define_method, "#{attr_name}=" do |value|
        self.settings[attr_name] ||= args[:default]
        self.settings[attr_name] = value
      end
    end
  end
  
  serialize :settings, Hash
 
  has_setting :color, :default => "000000"
  
  belongs_to :scrumbler_sprint
  
  has_many :trackers

  validates_uniqueness_of :tracker_id, :scope => :scrumbler_sprint_id, :if => :new_record?


  def after_initialize
    self.settings ||= {}
  end
  
   
  
end
