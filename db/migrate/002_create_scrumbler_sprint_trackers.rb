class CreateScrumblerSprintTrackers < ActiveRecord::Migration
  def self.up
    create_table :scrumbler_sprint_trackers do |t|
      t.references :scrumbler_sprint
      t.references :tracker
      t.integer :priority, :default => 500, :nil => false
      t.binary :settings
    end
    add_index :scrumbler_sprint_trackers, :priority
  end

  def self.down
    remove_index :scrumbler_sprint_trackers, :priority
    drop_table :scrumbler_sprint_trackers
  end
end
