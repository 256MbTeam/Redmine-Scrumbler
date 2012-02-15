class CreateScrumblerSprints < ActiveRecord::Migration
  def self.up
    create_table :scrumbler_sprints do |t|
      t.references :project
      t.references :version
    end
    
  end

  def self.down
    drop_table :scrumbler_sprints
  end
end
