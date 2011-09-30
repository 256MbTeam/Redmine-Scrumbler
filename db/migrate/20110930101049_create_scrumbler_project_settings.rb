class CreateScrumblerProjectSettings < ActiveRecord::Migration
  def self.up
    create_table :scrumbler_project_settings do |t|
      t.references :project
      t.binary :settings
      t.binary :maintrackers
    end
  end

  def self.down
    drop_table :scrumbler_project_settings
  end
end
