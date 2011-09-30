class ScrumblerSprintsController < ScrumblerAbstractController
  unloadable

  before_filter :find_scrumbler_sprint
  
  def settings
    
  end
  
  private
  def find_scrumbler_sprint
    @scrumbler_sprint = @project.scrumbler_sprints.find(params[:id])
  end
  
end
