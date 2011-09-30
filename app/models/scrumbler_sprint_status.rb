class ScrumblerSprintStatus < ActiveRecord::Base
  unloadable
  
  belongs_to :scrumbler_sprint
  
  has_many :issue_statuses
end
