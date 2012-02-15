class UpdateScrumblerSprintsStartDate < ActiveRecord::Migration
  def self.up
    add_column :scrumbler_sprints, :start_date, :date
  end

  def self.down
    remove_column :scrumbler_sprints, :start_date
  end
end
