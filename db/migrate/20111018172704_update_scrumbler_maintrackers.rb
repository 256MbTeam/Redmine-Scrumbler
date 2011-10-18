class UpdateScrumblerMaintrackers < ActiveRecord::Migration
  def self.up
    drop_table :scrumbler_maintrackers
    drop_table :scrumbler_sprint_statuses
    drop_table :scrumbler_sprint_trackers
    
    remove_column :scrumbler_project_settings, :maintrackers
    
    add_column :scrumbler_sprints, :settings, :binary
  end

  def self.down
#    
  end
end
