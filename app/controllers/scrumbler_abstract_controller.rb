class ScrumblerAbstractController < ApplicationController
  unloadable

  before_filter :find_project

  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    @scrumbler_project_setting = find_or_create_scrumbler_project_setting
  end
  
  def find_or_create_scrumbler_project_setting
    @project.scrumbler_project_setting ||= ScrumblerProjectSetting.new(:settings => {}, :maintrackers => [])
  end
  
end
