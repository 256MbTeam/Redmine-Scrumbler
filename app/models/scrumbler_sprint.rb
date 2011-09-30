class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  default_scope :include => [:version]
  
  belongs_to :project
  belongs_to :version
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
  
  delegate :name, :to => :version
  
  
end
