class ScrumblerAbstractController < ApplicationController
  unloadable

  before_filter :find_project

  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  end
  
end
