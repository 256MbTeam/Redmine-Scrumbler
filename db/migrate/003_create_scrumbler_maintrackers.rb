class CreateScrumblerMaintrackers < ActiveRecord::Migration
  def self.up
    create_table :scrumbler_maintrackers do |t|
      t.references :project
      t.references :tracker
    end
  end

  def self.down
    drop_table :scrumbler_maintrackers
  end
end
