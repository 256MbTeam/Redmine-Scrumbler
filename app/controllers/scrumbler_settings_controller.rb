class ScrumblerSettingsController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def show
  end
  
  def update_maintrackers
    params[:scrumbler_maintrackers] ||= []
    
    @scrumbler_project_setting.maintrackers = params[:scrumbler_maintrackers].map &:to_i
    @scrumbler_project_setting.save
    redirect_to project_scrumbler_settings_url(@project)
  end
  
end
