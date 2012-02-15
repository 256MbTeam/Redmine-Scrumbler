class UpdateScrumblerSprintsStatus < ActiveRecord::Migration
  def self.up
    add_column :scrumbler_sprints, :status, :string
  end

  def self.down
    remove_column :scrumbler_sprints, :status
  end
end
