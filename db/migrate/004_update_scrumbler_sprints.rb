class UpdateScrumblerSprints < ActiveRecord::Migration
  def self.up
     add_column :scrumbler_sprints, :max_points, :integer, :default => 0, :null => false
  end

  def self.down
     remove_column :scrumbler_sprints, :max_points
  end
end
