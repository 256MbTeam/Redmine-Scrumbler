class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  default_scope :include => [:version]
  
  belongs_to :project
  belongs_to :version
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
  

  delegate :name, :to => :version
  
  def self.crate_if_not_exists(project_id, version_id)
    sprint_hash = {:project_id => project_id, :version_id => version_id}
    unless ScrumblerSprint.exists?(sprint_hash)
      ScrumblerSprint.create(sprint_hash)
    end
  end
  
  def self.destroy_if_exists(project_id, version_id)
    ScrumblerSprint.destroy_all(:project_id => project_id, :version_id => version_id)
  end

  
end
