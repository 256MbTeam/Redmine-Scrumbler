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

module ScrumberHelper
  def select_color_tag(name, value=nil, options={})
    out = hidden_field_tag(name, value, options)
    out << javascript_tag("new TinyColorChooser(\"#{sanitize_to_id(name)}\", #{options.to_json})");
  end
  
  def draw_scrumbler_dashboard(sprint)
    div_id = "dashboard_for_sprint_#{sprint.id}"
    config = {
      :sprint => sprint,
      :project => sprint.project,
      :statuses => sprint.scrumbler_sprint_statuses,
      :trackers => Hash[*sprint.scrumbler_sprint_trackers.map{|t| [t.tracker_id,t]}.flatten],
      :issues => sprint.issues,
      :url => project_url(sprint.project)
    }.to_json
    out = "<div id='#{div_id}'></div>"
    out << javascript_tag("new ScrumblerDashboard('#{div_id}', #{config})")
  end
  
end
