class ScrumblerController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def index
    @versions
  end
  
  def settings
    
  end
  
  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  end
end
