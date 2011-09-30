class ScrumblerSprintTracker < ActiveRecord::Base
  unloadable
  
  belongs_to :scrumbler_sprint
  
  has_many :trackers
  serialize :settings, Hash
end
