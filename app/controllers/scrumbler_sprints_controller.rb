class ScrumblerSprintsController < ScrumblerAbstractController
  unloadable

  before_filter :find_scrumbler_sprint
  
  def settings
    @trackers = @project.trackers
    @issue_statuses = IssueStatus.all
  end
  
  def update_trackers
    @existing_sprint_trackers_ids = @scrumbler_sprint.scrumbler_sprint_trackers.map &:tracker_id
    @new_sprint_trackers_ids =  params[:scrumbler_sprint][:scrumbler_sprint_trackers].delete_if(&:blank?).map(&:to_i)

    @to_create_trackers_ids  = @new_sprint_trackers_ids - @existing_sprint_trackers_ids
    @to_destroy_trackers_ids = @existing_sprint_trackers_ids - @new_sprint_trackers_ids
    
    ScrumblerSprintTracker.transaction do
      begin
        if @to_create_trackers_ids.any?
          @to_create_trackers_ids.each {|tracker_id| @scrumbler_sprint.scrumbler_sprint_trackers.create(:tracker_id => tracker_id) }
        end
      
        if @to_destroy_trackers_ids.any?
          ScrumblerSprintTracker.delete_all(["tracker_id in(?) and scrumbler_sprint_id = ?", @to_destroy_trackers_ids, @scrumbler_sprint.id])
        end
      rescue
        flash[:error] = t :error_scrumbler_maintrackers_update
      end
    end
      
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to settings_project_scrumbler_sprint_url(@project, @scrumbler_sprint)

      
  end
  
  private
  def find_scrumbler_sprint
    @scrumbler_sprint = @project.scrumbler_sprints.find(params[:id])
  end
  
end
