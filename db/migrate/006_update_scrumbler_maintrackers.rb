class UpdateScrumblerMaintrackers < ActiveRecord::Migration
  def self.up
    remove_index :scrumbler_sprint_statuses, :priority
    drop_table :scrumbler_maintrackers
    drop_table :scrumbler_sprint_statuses
    drop_table :scrumbler_sprint_trackers
    
    remove_column :scrumbler_project_settings, :maintrackers
    
    add_column :scrumbler_sprints, :settings, :binary
  end

  def self.down
    create_table :scrumbler_maintrackers do |t|
      t.references :project
      t.references :tracker
    end
    
    create_table :scrumbler_sprint_statuses do |t|
      t.references :scrumbler_sprint
      t.references :issue_status
      t.integer :priority, :default => 500, :nil => false
    end
    add_index :scrumbler_sprint_statuses, :priority
    
    create_table :scrumbler_sprint_trackers do |t|
      t.references :scrumbler_sprint
      t.references :tracker
      t.integer :priority, :default => 500, :nil => false
      t.binary :settings
    end
    add_index :scrumbler_sprint_trackers, :priority
    
    remove_column :scrumbler_sprints, :settings
    
    add_column :scrumbler_project_settings, :maintrackers, :binary
  end
end
