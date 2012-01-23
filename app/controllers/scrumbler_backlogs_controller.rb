# To change this template, choose Tools | Templates
# and open the template in the editor.
class ScrumblerBacklogsController < ScrumblerAbstractController
  unloadable
  def index

  end

  def add_issue_to_sprint
    @issue = Issue.find(params[:issue_id])
    @sprint = ScrumblerSprint.find(params[:sprint_id])

    @issue.fixed_version =@sprint.version
    @issue.save

    # render :json => {:success => @issue.save, :issue => issue_for_json(@issue)}
    render :partial => "sprint", :sprint => ScrumblerSprint.find(params[:sprint_id])
  end

  def remove_issue_from_sprint
    @issue = Issue.find(params[:issue_id])
    @sprint = ScrumblerSprint.find(params[:sprint_id])
  end
end
