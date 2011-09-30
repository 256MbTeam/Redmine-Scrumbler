class ScrumblerController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def index
    @scrumbler_sprints = @project.scrumbler_sprints
  end
  
  def sprint
    @sprint = @project.scrumbler_sprints.find(params[:sprint_id])
    render :update do |page|
        page.replace_html 'scrumbler_sprint', :partial => 'sprint', :object => @sprint
    end
  end
  
end
