class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  default_scope :include => [:version]
  
  belongs_to :project
  belongs_to :version
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
  

  delegate :name, :to => :version
  
  def self.create_if_not_exists(project_id, version_id)
    sprint_hash = {:project_id => project_id, :version_id => version_id}
    unless ScrumblerSprint.exists?(sprint_hash)
      ScrumblerSprint.create(sprint_hash)
    end
  end
  
  def self.create_sprints_for_project(project_id)
    @versions = Version.find(:all, :conditions => {:project_id => project_id})
    @versions.each do |version|
      create_if_not_exists(project_id, version.id)
    end
  end
  
  def self.destroy_if_exists(project_id, version_id)
    destroy_all(:project_id => project_id, :version_id => version_id)
  end

  def self.destroy_all_in_project(project_id)
    destroy_all(:project_id => project_id)
  end

end
