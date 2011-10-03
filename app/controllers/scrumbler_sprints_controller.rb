class ScrumblerSprintsController < ScrumblerAbstractController
  unloadable

  before_filter :find_scrumbler_sprint
  
  def settings
    @trackers = @project.trackers
    @enabled_trackers_ids = @scrumbler_sprint.scrumbler_sprint_trackers.map(&:tracker_id)
    @issue_statuses = IssueStatus.all
  end
  
  def update_trackers
    # Удаление пустых данных
    params[:scrumbler_sprint][:scrumbler_sprint_trackers].delete_if { |obj|  !obj[:tracker_id]}
    
    # Выборка ID существующих трекеров
    @existing_sprint_trackers_ids = @scrumbler_sprint.scrumbler_sprint_trackers.map &:tracker_id
    
    # Выборка ID трекеров из параметров
    @new_sprint_trackers_ids =  params[:scrumbler_sprint][:scrumbler_sprint_trackers].map {|obj| obj[:tracker_id].to_i}

    # Выборка трекеров для создания
    @to_create_trackers = params[:scrumbler_sprint][:scrumbler_sprint_trackers].find_all { |e| !@existing_sprint_trackers_ids.include? e[:tracker_id].to_i }
    
    # Выборка трекеров для обновления
    @to_update_trackers = params[:scrumbler_sprint][:scrumbler_sprint_trackers] - @to_create_trackers
    
    # Выборка трекеров для удаления
    @to_destroy_trackers_ids = @existing_sprint_trackers_ids - @new_sprint_trackers_ids

    ScrumblerSprintTracker.transaction do
      begin
        if @to_create_trackers.any?
          @to_create_trackers.each {|tracker_params| @scrumbler_sprint.scrumbler_sprint_trackers.create(tracker_params) }
        end
      
        if @to_update_trackers.any?
          @to_update_trackers.each {|tracker_params|
            sprint_tracker = @scrumbler_sprint.scrumbler_sprint_trackers.first(:conditions => {:tracker_id => tracker_params[:tracker_id]})
            sprint_tracker.update_attributes!(tracker_params)
          }
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
