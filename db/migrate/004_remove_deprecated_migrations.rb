class RemoveDeprecatedMigrations < ActiveRecord::Migration
  def self.up
    Scrumbler::Migration.delete_migrations "20110929130914-redmine_scrumbler",
    "20110929132646-redmine_scrumbler",
    "20110929133445-redmine_scrumbler",
    "20110929133601-redmine_scrumbler",
    "20110930101049-redmine_scrumbler",
    "20111018172704-redmine_scrumbler",
    "20111018172705-redmine_scrumbler",
    "20111018172706-redmine_scrumbler",
    "20111018172707-redmine_scrumbler"
  end

  def self.down
  end
end
