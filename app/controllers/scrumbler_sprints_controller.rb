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

  before_filter :find_scrumbler_sprint, :except => [:create]
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
    if params[:scrumbler_sprint][:status] == ScrumblerSprint::CLOSED && Issue.open.exists?(:id => @scrumbler_sprint.issues.map(&:id))
      render :close_confirm
    return
    end
    ScrumblerSprint.connection.transaction do
      unless @scrumbler_sprint.update_attributes({:status => params[:scrumbler_sprint][:status], :start_date => params[:scrumbler_sprint][:start_date], :end_date => params[:scrumbler_sprint][:end_date]})
        flash[:error] ||= ""
        @scrumbler_sprint.errors.each_full{|msg|
          flash[:error] << msg.to_s
        }
      end
      @version = @scrumbler_sprint.version
      unless @version.update_attributes({:name => params[:scrumbler_sprint][:name], :description => params[:scrumbler_sprint][:description]})
        flash[:error] ||= ""
        @version.errors.each_full{|msg|
          flash[:error] << msg.to_s
        }
      end
      raise ActiveRecord::Rollback if flash[:error]
    end
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
      @issue.init_journal(User.current)
      {:success => @issue.update_attributes(params[:issue])}

    else
      new_status = IssueStatus.find(params[:issue][:status_id])
      {:success => false, :text => l(:error_scrumbler_issue_status_change, :status_name => new_status.name)}
    end
    render :json => @message
  end

  def change_issue_assignment_to_me
    @issue = Issue.find(params[:issue_id])
    @issue.assigned_to = User.current
    @issue.init_journal(User.current)
    render :json => {:success => @issue.save, :issue => issue_for_json(@issue)}
  end

  def drop_issue_assignment
    @issue = Issue.find(params[:issue_id])
    if @issue.assigned_to == User.current
      @issue.assigned_to = nil
      @issue.init_journal(User.current)
      render :json => {:success => @issue.save, :issue => issue_for_json(@issue)}
    else
      render :status => 403
    end
  end

  def burndown
    @burndown = burndown_calc
  end

  def close_confirm
    errors = []
    action = params[:issue_action]
    @issues = @scrumbler_sprint.issues;
    if action == 'close'
      Issue.connection.transaction do
        @issues.each{|issue|
          issue.status = IssueStatus.find(:first, :conditions => {:is_closed => true})
          issue.init_journal(User.current)
          issue.errors.each_full{|msg| errors <<  msg.to_s } unless issue.save
        }
        @scrumbler_sprint.status = ScrumblerSprint::CLOSED
        @scrumbler_sprint.errors.each_full{|msg| errors <<  msg.to_s } unless @scrumbler_sprint.save
      end
    elsif action == 'backlog'
      Issue.connection.transaction do
        @issues.each{|issue|
          issue.fixed_version_id = nil
          issue.init_journal(User.current)
          issue.errors.each_full{|msg| errors <<  msg.to_s } unless issue.save
        }
        @scrumbler_sprint.status = ScrumblerSprint::CLOSED
        @scrumbler_sprint.errors.each_full{|msg| errors <<  msg.to_s } unless @scrumbler_sprint.save
      end
    end
    
    flash[:error] = errors if !errors.empty?
    
    flash[:notice] = t :notice_successful_update unless flash[:error]
    
    redirect_to project_scrumbler_sprint_settings_url(@project, @scrumbler_sprint)
  end

  private

  def burndown_calc
    out = {}
    start_date = @scrumbler_sprint.start_date

    end_date  = @scrumbler_sprint.end_date || Date.today

    closed_issues = @scrumbler_sprint.issues.find_all {|i| i.due_date && i.closed?}
    closed_issues = Hash[closed_issues.group_by(&:due_date).map {|k,v|
      [k, v.inject(0.0) {|t,is|
          t+= is.custom_value_for(ScrumblerIssueCustomField.points).try(:value).to_f }
      ]}]

    days_total = (end_date - start_date).to_i

    points_total_normal = @scrumbler_sprint.points_total
    points_total_real = @scrumbler_sprint.points_total

    points_per_day_normal = points_total_normal/days_total.to_f

    out[:normal] = []
    out[:real] = []
    (days_total+1).times {|day_num|
      cycle_date = (start_date + day_num)
      js_date = cycle_date.to_time.to_i*1000
      out[:normal] << [js_date, points_total_normal]
      out[:real] << [js_date, points_total_real -= closed_issues[cycle_date].to_f]
      points_total_normal = (points_total_normal - points_per_day_normal).round(2)
      points_total_normal = 0 if points_total_normal < 0
    }
    out
  end

  def find_scrumbler_sprint
    @scrumbler_sprint = @project.scrumbler_sprints.find(params[:id])
  end

end
