class ScrumblerProjectSetting < ActiveRecord::Base
  unloadable
  belongs_to :project
  
  serialize :settings, Hash
  serialize :maintrackers, Array
  
  def after_initialize
    self.settings ||= {}
    self.maintrackers ||= []
  end
end
