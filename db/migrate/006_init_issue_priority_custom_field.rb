class InitIssuePriorityCustomField < ActiveRecord::Migration
  def self.up
    ScrumblerIssueCustomField.priority
  end

  def self.down
    ScrumblerIssueCustomField.priority.destroy
  end
end
