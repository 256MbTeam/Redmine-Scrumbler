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

module ScrumblerHelper

  #  def select_color_tag(params)
  #    x_id = "color_#{params[:id]}"
  #    previev_element_id = "#{params[:id]}_preview"
  #    out = text_field_tag params[:name], params[:value], {
  #      :class => 'color_input',
  #      :x_id => x_id,
  #      :size => 6
  #    }
  #    out << "<div id='#{previev_element_id}' class='color_preview' style='background-color: #{params[:value]};'></div>"
  #    picker_config = {
  #      :color => params[:value],
  #      :previewElement => previev_element_id
  #    }.to_json
  #    
  #    out << javascript_tag("new colorPicker($$('input[x_id=#{x_id}]')[0], #{picker_config})")
  #  end
 
  def select_color_tag(name, value=nil, options={})
    out = hidden_field_tag(name, value, options)
    out << javascript_tag("new TinyColorChooser(\"#{sanitize_to_id(name)}\", #{options.to_json})");
  end
  
  def issue_for_json(issue)
    out = {
        :id => issue.id,
        :status_id => issue.status_id,
        :tracker_id => issue.tracker_id,
        :project_id => issue.project_id,
        :subject => issue.subject
        
      }
      out[:assigned_to] = {:id   => issue.assigned_to_id, :name => issue.assigned_to.name } if issue.assigned_to
      
      out
  end
  
  def draw_scrumbler_dashboard(sprint)
    div_id = "dashboard_for_sprint_#{sprint.id}"
    prepared_issues = sprint.issues.map {|issue| issue_for_json(issue) }
    puts "sdafasdfsa\n"*88
    p User.current.id
    config = {
      :sprint => sprint,
      :project => sprint.project,
      :statuses => sprint.scrumbler_sprint_statuses,
      :trackers => Hash[*sprint.scrumbler_sprint_trackers.map{|t| [t.tracker_id,t]}.flatten],
      :issues => prepared_issues,
      :url => project_url(sprint.project),
      :current_user_id => User.current.id
    }.to_json
    out = "<div id='#{div_id}'></div>"
    out << javascript_tag("new ScrumblerDashboard('#{div_id}', #{config})")
  end
  
end
