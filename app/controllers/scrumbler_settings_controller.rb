class ScrumblerSettingsController < ScrumblerAbstractController
  unloadable

  #  before_filter :authorize, :only => [:settings]
  
  def show
  end
  
  def update_maintrackers
    params[:scrumbler_maintrackers] ||= []
    ScrumblerProjectSetting.transaction do
      unless @scrumbler_project_setting.update_attributes(:maintrackers => params[:scrumbler_maintrackers].map(&:to_i))
        flash[:error] = t :error_scrumbler_maintrackers_update
      end
    end
    
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_settings_url(@project)
  end
  
end
