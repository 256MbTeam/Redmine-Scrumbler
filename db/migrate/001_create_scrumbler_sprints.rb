class CreateScrumblerSprints < ActiveRecord::Migration
  def self.up
    return if Scrumbler::Migration.migration_exist? "20110929130914-redmine_scrumbler",
    "20111018172706-redmine_scrumbler",
    "20111018172707-redmine_scrumbler",
    "20111018172704-redmine_scrumbler"  
    
    
    create_table :scrumbler_sprints, :force => true do |t|
      t.references :project
      t.references :version
      t.binary :settings
      t.string :status
      t.date :start_date
    end
    
  end

  def self.down
    drop_table :scrumbler_sprints
  end
end
