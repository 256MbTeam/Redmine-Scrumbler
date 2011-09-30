class ScrumblerSprint < ActiveRecord::Base
  unloadable
  
  default_scope :include => [:version]
  
  belongs_to :project
  belongs_to :version
  
  has_many :scrumbler_sprint_trackers
  has_many :scrumbler_sprint_statuses
  

  delegate :name, :to => :version
  
  
  class << self
    def crate_if_not_exists(project_id, version_id)
      sprint_hash = {:project_id => project_id, :version_id => version_id}
      unless exists?(sprint_hash)
        create(sprint_hash)
      end
    end
  
    def destroy_if_exists(project_id, version_id)
      destroy_all(:project_id => project_id, :version_id => version_id)
    end
  end
  

  
end
