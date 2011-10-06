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
  helper ScrumberSprintsHelper
  def settings
    @trackers = @project.trackers
    @enabled_trackers_ids = @scrumbler_sprint.scrumbler_sprint_trackers.map(&:tracker_id)
    @issue_statuses = IssueStatus.all
    @enabled_issue_statuses = Hash[*@scrumbler_sprint.scrumbler_sprint_statuses.map{|s| [s.issue_status_id, s] }.flatten]
  end
  
  def update_trackers
    # delete empty data
    params[:scrumbler_sprint][:scrumbler_sprint_trackers].delete_if { |obj|  !obj[:tracker_id]}
    
    # select existing trackers id
    @existing_sprint_trackers_ids = @scrumbler_sprint.scrumbler_sprint_trackers.map &:tracker_id
    
    # trackers id from params
    @new_sprint_trackers_ids =  params[:scrumbler_sprint][:scrumbler_sprint_trackers].map {|obj| obj[:tracker_id].to_i}

    # select trackers for create
    @to_create_trackers = params[:scrumbler_sprint][:scrumbler_sprint_trackers].find_all { |e| !@existing_sprint_trackers_ids.include? e[:tracker_id].to_i }
    
    # select trackers for update
    @to_update_trackers = params[:scrumbler_sprint][:scrumbler_sprint_trackers] - @to_create_trackers
    
    # select trackers for destroy
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
      rescue Exception => e  
        puts e.message  
        puts e.backtrace.inspect
        flash[:error] = t :error_scrumbler_maintrackers_update
      end
    end
      
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :trackers)

  end
  
  def update_issue_statuses
    @statuses = {
      :enabled => @scrumbler_sprint.scrumbler_sprint_statuses.map(&:issue_status_id),
      :update => [],
      :create => [],
      :destroy => []
    }
   
    params[:scrumbler_issue_statuses].each {|status_id, val| 
      status_id = status_id.to_i
      if val.delete(:enabled)
        key = @statuses[:enabled].include?(status_id) ? :update : :create
        @statuses[key] << val.merge({:issue_status_id => status_id})
      else
        @statuses[:destroy] << status_id
      end
    }
    
    
    ScrumblerSprintStatus.transaction do
      begin
        @statuses[:create].each {|status| @scrumbler_sprint.scrumbler_sprint_statuses.create(status) }
          
        @statuses[:update].each {|status|
          sprint_tracker = @scrumbler_sprint.scrumbler_sprint_statuses.first(:conditions => {:issue_status_id => status[:issue_status_id]})
          sprint_tracker.update_attributes!(status)
        }
      
        if @statuses[:destroy].any?
          ScrumblerSprintStatus.delete_all(["issue_status_id in(?) and scrumbler_sprint_id = ?", @statuses[:destroy], @scrumbler_sprint.id])
        end
      rescue Exception => e
        flash[:error] = t :error_scrumbler_maintrackers_update
      end
    end
      
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint, :issue_statuses)
    
  end
  
  def update_issue
    
    @issue = Issue.find(params[:issue_id])
    
    @message = if @issue.new_statuses_allowed_to(User.current).map(&:id).include?(params[:issue][:status_id].to_i)
      if @issue.update_attributes(params[:issue])
        {:success => true}
      else
        {:success => false}
      end
    else
      new_status = IssueStatus.find(params[:issue][:status_id])
      {:success => false, :text => l(:error_scrumbler_issue_status_change, :status_name => new_status.name)}
    end
    

    render :json => @message
  end
  
  private
  def find_scrumbler_sprint
    @scrumbler_sprint = @project.scrumbler_sprints.find(params[:id])
  end
  
end
