class ScrumblerMaintracker < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :tracker
  
end
