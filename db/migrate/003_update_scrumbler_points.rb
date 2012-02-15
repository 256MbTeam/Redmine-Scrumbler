class UpdateScrumblerPoints < ActiveRecord::Migration
  def self.up
    return if Scrumbler::Migration.migration_exist? "20111018172705-redmine_scrumbler"
    points_field = ScrumblerIssueCustomField.points
    old_value = points_field.possible_values[2]
    
    points_field.possible_values[2] = "0.5"
    points_field.save
    
    CustomValue.update_all({
        :value => points_field.possible_values[2]
      }, 
      {
        :custom_field_id => points_field.id, 
        :value => old_value
      })
    
  end

  def self.down
    ScrumblerIssueCustomField.points.destroy
  end
end
