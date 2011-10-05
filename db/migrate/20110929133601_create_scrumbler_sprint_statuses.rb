class CreateScrumblerSprintStatuses < ActiveRecord::Migration
  def self.up
    create_table :scrumbler_sprint_statuses do |t|
      t.references :scrumbler_sprint
      t.references :issue_status
      t.integer :priority, :default => 500, :nil => false
    end
    
    add_index :scrumbler_sprint_statuses, :priority
  end

  def self.down
    remove_index :scrumbler_sprint_statuses, :priority
    drop_table :scrumbler_sprint_statuses
  end
end
