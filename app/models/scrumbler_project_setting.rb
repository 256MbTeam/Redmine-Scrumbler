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
  unloadable

  #  Default colors, uses for color_chooser
  DEFAULT_COLOR_MAP = %w(faf faa afa aaf ffa aff)

  validates_presence_of :project
  belongs_to :project

  serialize :settings, HashWithIndifferentAccess
  def find_tracker(id)
    self.settings[:trackers][id.to_s] || ScrumblerProjectSetting.create_setting(Tracker.find(id), false)
  end

  def find_issue_status(id)
    self.settings[:issue_statuses][id.to_s] || ScrumblerProjectSetting.create_setting(IssueStatus.find(id), false)
  end

  def trackers
    self.settings[:trackers]
  end

  def issue_statuses
    self.settings[:issue_statuses]
  end

  def before_save
    if self.new_record?
      self.settings ||= HashWithIndifferentAccess.new

      if !self.settings[:issue_statuses] || self.settings[:issue_statuses].empty?
        self.settings[:issue_statuses] =  HashWithIndifferentAccess.new

        IssueStatus.all.each {|status|
          self.settings[:issue_statuses][status.id.to_s] = ScrumblerProjectSetting.create_setting(status)
        }
      end

      if !self.settings[:trackers] || self.settings[:trackers].empty?
        self.settings[:trackers] =  HashWithIndifferentAccess.new
        trackers = self.project.trackers
        trackers = Tracker.all if trackers.empty?
        trackers.each {|tracker|
          self.settings[:trackers][tracker.id.to_s] = ScrumblerProjectSetting.create_setting(tracker)
        }
      end

    end
  end

  #  Create default setting
  def self.create_setting(object, use = true)
    if object.class == Tracker
      HashWithIndifferentAccess.new(
      {
        :id=>object.id,
        :use => use,
        :position => object.position,
        :color => DEFAULT_COLOR_MAP[(object.id % DEFAULT_COLOR_MAP.size)]
      }
    )
    elsif object.class == IssueStatus
      HashWithIndifferentAccess.new(
      {
        :id=>object.id,
        :use => use,
        :position => object.position
      }
    )
    end
  end
end
