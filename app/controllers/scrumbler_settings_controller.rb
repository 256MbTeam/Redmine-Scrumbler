class ScrumblerSettingsController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def show
  end
  
  def update_maintrackers
    params[:scrumbler_maintrackers] ||= []
    
    @scrumbler_project_setting.update_attributes(:maintrackers => params[:scrumbler_maintrackers].map(&:to_i))
    redirect_to project_scrumbler_settings_url(@project)
  end
  
end
