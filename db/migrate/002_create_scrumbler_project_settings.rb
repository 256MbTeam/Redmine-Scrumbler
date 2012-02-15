class CreateScrumblerProjectSettings < ActiveRecord::Migration
  def self.up
    return if Scrumbler::Migration.migration_exist? "20110930101049-redmine_scrumbler",
                                                    "20111018172704-redmine_scrumbler"  
    
    create_table :scrumbler_project_settings, :force => true do |t|
      t.references :project
      t.binary :settings
    end
  end

  def self.down
    drop_table :scrumbler_project_settings
  end
end
