class ScrumblerController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def index
    @scrumbler_sprints = @project.scrumbler_sprints
  end
  
end
