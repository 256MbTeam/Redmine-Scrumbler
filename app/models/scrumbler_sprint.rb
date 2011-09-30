class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :version
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
end
