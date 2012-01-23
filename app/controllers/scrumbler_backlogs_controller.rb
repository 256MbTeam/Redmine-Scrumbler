# To change this template, choose Tools | Templates
# and open the template in the editor.
class ScrumblerBacklogsController < ScrumblerAbstractController
  unloadable
  def index

  end

  def prepare_issues_for_json(issues)
    issues.map{|issue|
      { :id => issue.id,
        :subject => issue.subject }
    }
  end

  def change_issue_version
    @issue = Issue.find(params[:issue_id])

    @sprint = ScrumblerSprint.find_by_version_id(@issue.fixed_version_id)
    if @sprint #  Move from sprint to backlog
      @issue.fixed_version_id = nil
    else # Move from backlog to sprint
      @sprint = ScrumblerSprint.find(params[:sprint_id])
      @issue.fixed_version_id = @sprint.version_id
    end

    render :json => { :success => @issue.save,
                      :backlog => prepare_issues_for_json(@project.issues.without_version),
                      :sprint => prepare_issues_for_json(@sprint.issues),
                      :text => @issue.errors.map
                    }
  end

  def add_issue_to_sprint
    @issue = Issue.find(params[:issue_id])
    @sprint = ScrumblerSprint.find(params[:sprint_id])

    @issue.save

    render :json => {:success => @issue.save, :sprint => ScrumblerSprint.find(params[:sprint_id])}
  # render :partial => "sprint", :sprint => ScrumblerSprint.find(params[:sprint_id])
  end

  def remove_issue_from_sprint
    @issue = Issue.find(params[:issue_id])
    @sprint = ScrumblerSprint.find(params[:sprint_id])
  end
end
