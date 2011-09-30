class ScrumblerSettingsController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def show
    puts "sdf"
    p @scrumbler_project_setting
  end
  
  def update_maintrackers
    
  end
  
end
