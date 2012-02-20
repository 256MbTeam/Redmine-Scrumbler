class AddFactCloseDateFieldScrumblerSprints < ActiveRecord::Migration
  def self.up
    add_column :scrumbler_sprints, :fact_close_date, :date
  end

  def self.down
    remove_column :scrumbler_sprints, :fact_close_date
  end
end
