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
class ScrumblerBacklogsController < ScrumblerAbstractController
  unloadable
  
  before_filter :authorize, :only => [:show, :select_sprint, :create_version, :update_scrum_points, :change_issue_version, :open_sprint, :move_issue_priority]

  
  helper :custom_fields
  include CustomFieldsHelper
  

  helper :scrumbler_backlogs
  include ScrumblerBacklogsHelper
  
  def show
    @selected_sprint = @project.scrumbler_sprints.planning.first
  end

  def select_sprint
    @sprint = ScrumblerSprint.find(params[:sprint_id])
    
    render :json => { :success => !!@sprint,
                      :sprint => prepare_sprint_for_json(@sprint),
                      :text => t(:error_sprint_not_found)
                    }
  end

  def create_version
    @version = Version.new(:project => @project, :name => params[:sprint_name])
    render :json => {
                     :success => @version.save,
                     :sprint => prepare_sprint_for_json(@version.try(:scrumbler_sprint)),
                     :sprints => prepare_sprints(@project.scrumbler_sprints.planning)
                    }
  end

  def update_scrum_points
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current)
    
    params[:issue] = HashWithIndifferentAccess.new({
          "custom_field_values" => {
            ScrumblerIssueCustomField.points.id.to_s => params[:points]
          }
        })
    @issue.safe_attributes = params[:issue]

    render :json => { 
                      :success => @issue.save_issue_with_child_records(params[:issue]),
                      :text    => @issue.errors.full_messages.join(", <br>")
                    }
  end

  def change_issue_version
    @issue = Issue.find(params[:issue_id])
    @issue.init_journal(User.current)
    @sprint = ScrumblerSprint.find_by_version_id(@issue.fixed_version_id)
    if @sprint #  Move from sprint to backlog
      @issue.fixed_version_id = nil
    else # Move from backlog to sprint
      @sprint = ScrumblerSprint.find(params[:sprint_id])
      @issue.fixed_version_id = @sprint.version_id
    end

    render :json => { :success => @issue.save,
                      :backlog => prepare_backlog_for_json(@project),
                      :sprint => prepare_sprint_for_json(@sprint),
                      :text => @issue.errors.full_messages.join(", <br>")
                    }
  end
  
  def open_sprint
    @sprint = ScrumblerSprint.find(params[:sprint_id])
    @sprint.status = ScrumblerSprint::OPENED
    planning = @project.scrumbler_sprints.planning
    saved = @sprint.save
    render :json => {
                 :success => saved,
                 :sprint => prepare_sprint_for_json(saved ? planning.first : @sprint),
                 :sprints => prepare_sprints(planning),
                 :text => @sprint.errors.full_messages.join(", <br>")
                }
  end
  
  
  def move_issue issues, moved_issue, new_priority
    @issues.each{|issue|
        _priority = get_position.call(issue)
        if issue.id != moved_issue.id &&  ((_priority <= new_priority && _priority > moved_issue.priority) || 
          (_priority >= new_priority && _priority < moved_issue.priority)) 
           params[:issue] = HashWithIndifferentAccess.new({"custom_field_values" => {
              ScrumblerIssueCustomField.priority.id.to_s => (_priority-1).to_s
            }
          })
          issue.safe_attributes = params[:issue]
          issue.save_issue_with_child_records(params[:issue])
        end 
        
      }
      
    params[:issue] = HashWithIndifferentAccess.new({
        "custom_field_values" => {
          ScrumblerIssueCustomField.priority.id.to_s => (@new_priority).to_s
        }
      })
    @issue.safe_attributes = params[:issue]
    @saved = @issue.save_issue_with_child_records(params[:issue])
  end
  
  def move_issue_priority
    get_position = proc {|issue|
      issue.custom_value_for(ScrumblerIssueCustomField.priority).try(:value).to_i
    }
    sort_pos = proc {|a,b|
        get_position.call(a) <=> get_position.call(b)
    }
    @issue = Issue.find(params[:issue_id])
    @sprint = ScrumblerSprint.find(params[:sprint_id])
    
    @issues = @issue.fixed_version ? @sprint.issues : @project.issues.without_version


    priority = get_position.call(@issue)
    if "move_up" == params[:issue_action]
      
      @new_priority = get_position.call(@issues.select{|issue|
        _priority = get_position.call(issue)
        issue.id != @issue.id && _priority >= priority
      }.min &sort_pos)
      
      move_issue(@issues, @issue, @new_priority)
      
    elsif "move_down" == params[:issue_action]
      
        @new_priority = get_position.call(@issues.select{|issue|
        _priority = get_position.call(issue)
        issue.id != @issue.id && _priority <= priority
      }.max &sort_pos)
       
       @issues.each{|issue|
        _priority = get_position.call(issue)
        if issue.id != @issue.id &&  _priority >= @new_priority
           params[:issue] = HashWithIndifferentAccess.new({"custom_field_values" => {
              ScrumblerIssueCustomField.priority.id.to_s => (_priority+1).to_s
            }
          })
          issue.safe_attributes = params[:issue]
          issue.save_issue_with_child_records(params[:issue])
        end 
        
      }
    # elsif "top_up" == params[:issue_action]
          # @new_priority = get_position.call(@issues.select{|issue|
        # _priority = get_position.call(issue)
        # issue.id != @issue.id && _priority >= priority
      # }.min &sort_pos)
#        
       # @issues.each{|issue|
        # _priority = get_position.call(issue)
        # if issue.id != @issue.id &&  _priority <= @new_priority
           # params[:issue] = HashWithIndifferentAccess.new({"custom_field_values" => {
              # ScrumblerIssueCustomField.priority.id.to_s => (_priority-1).to_s
            # }
          # })
          # issue.safe_attributes = params[:issue]
          # issue.save_issue_with_child_records(params[:issue])
        # end 
#         
      # }
    # elsif "top_down" == params[:issue_action]
        # @new_priority = get_position.call(@issues.select{|issue|
        # _priority = get_position.call(issue)
        # issue.id != @issue.id && _priority <= priority
      # }.max &sort_pos)
#        
       # @issues.each{|issue|
        # _priority = get_position.call(issue)
        # if issue.id != @issue.id &&  _priority >= @new_priority
           # params[:issue] = HashWithIndifferentAccess.new({"custom_field_values" => {
              # ScrumblerIssueCustomField.priority.id.to_s => (_priority+1).to_s
            # }
          # })
          # issue.safe_attributes = params[:issue]
          # issue.save_issue_with_child_records(params[:issue])
        # end 
#         
      # }
    end


    
    render :json => {
             :success => @saved,
             :sprint => prepare_sprint_for_json(@sprint),
             :backlog => prepare_backlog_for_json(@project),
             :text => @issue.errors.full_messages.join(", <br>")
            }
  end
  
  def create_issue
    @issue = Issue.new(params[:issue])
    @issue.project = @project
    @issue.author = User.current
    @issue.tracker ||= Tracker.first
    @issue.safe_attributes = params[:issue]

    if request.get? || (request.post? && !@issue.valid?)
      render :layout => false
    else
      render :json => {
      :success => @issue.save,
      :backlog => prepare_backlog_for_json(@project),
      :text => @issue.errors.full_messages.join(", <br>")
    }
    end

  end
  
end
