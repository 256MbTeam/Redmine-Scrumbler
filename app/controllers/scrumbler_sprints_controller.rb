# Scrumbler - Add scrum functionality to any Redmine installation
# Copyright (C) 2011 256Mb Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ScrumblerSprintsController < ScrumblerAbstractController
  unloadable

  before_filter :find_scrumbler_sprint
  before_filter :authorize, :only => [:settings, :update_general, :update_trackers, :update_issue_statuses]
  
  helper :scrumbler_sprints
  include ScrumblerSprintsHelper
  
  helper :scrumbler
  include ScrumblerHelper



  def settings
    @trackers = @project.trackers
    @issue_statuses = IssueStatus.all
    
    # Hashes
    @enabled_trackers = @scrumbler_sprint.trackers
    @enabled_statuses = @scrumbler_sprint.issue_statuses
  end
  
  def update_general
    flash[:error] = @scrumbler_sprint.errors.on_base unless @scrumbler_sprint.update_attributes({:status => params[:scrumbler_sprint][:status], :start_date => params[:scrumbler_sprint][:start_date], :end_date => params[:scrumbler_sprint][:end_date]})  
    
    @version = @scrumbler_sprint.version
    flash[:error] = @version.errors.on_base unless @version.update_attributes({:name => params[:scrumbler_sprint][:name], :description => params[:scrumbler_sprint][:description]}) 
          
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :general)
  end
  
  def update_trackers
    #    TODO add id to settings[:trackers] (dont forget change tests and views)
    params[:scrumbler_sprint][:trackers].delete_if { |k, v|  !v[:use]}
    @scrumbler_sprint.settings[:trackers] = params[:scrumbler_sprint][:trackers]
    
    flash[:error] = t :error_scrumbler_trackers_update unless @scrumbler_sprint.save 
          
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :trackers)
  end
  
  def update_issue_statuses
    params[:scrumbler_sprint][:issue_statuses].delete_if { |k, v|  !v[:use]}
    @scrumbler_sprint.settings[:issue_statuses] =  params[:scrumbler_sprint][:issue_statuses]
    flash[:error] = t :error_scrumbler_trackers_update unless @scrumbler_sprint.save
      
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :issue_statuses)
  end
  
  def update_issue
    @issue = Issue.find(params[:issue_id])
    @message = if @issue.new_statuses_allowed_to(User.current).map(&:id).include?(params[:issue][:status_id].to_i)
      # Set start date if issue is new
      params[:issue][:start_date] = Date.today if @issue.status == IssueStatus.default
      params[:issue][:due_date] = nil if @issue.due_date && @issue.due_date < Date.today
      
      # Set due date if issue closed
      params[:issue][:due_date] = Date.today if IssueStatus.exists?(:is_closed => true, :id => params[:issue][:status_id])

      
      {:success => @issue.update_attributes(params[:issue])}

    else
      new_status = IssueStatus.find(params[:issue][:status_id])
      {:success => false, :text => l(:error_scrumbler_issue_status_change, :status_name => new_status.name)}
    end
    p @issue.errors
    render :json => @message
  end
  
  def change_issue_assignment_to_me
    @issue = Issue.find(params[:issue_id])
    @issue.assigned_to = User.current
    render :json => {:success => @issue.save, :issue => issue_for_json(@issue)}
  end
  
  def drop_issue_assignment
    @issue = Issue.find(params[:issue_id])
    if @issue.assigned_to == User.current
      @issue.assigned_to = nil
      render :json => {:success => @issue.save, :issue => issue_for_json(@issue)}
    else
      render :status => 403
    end
  end
  
  def burndown
    @data = []
    10.times {|i|
      @data << [i.days.since.to_i*1000, rand(100)]
    }
  end
  
  private
  def find_scrumbler_sprint
    @scrumbler_sprint = @project.scrumbler_sprints.find(params[:id])
  end
  
end
