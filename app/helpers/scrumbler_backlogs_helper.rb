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

module ScrumblerBacklogsHelper
  
  def draw_issues_list(config)
    
  end
  
  def scrumbler_sprints_tabs(sprints)
    tabs = []
    sprints.each do |sprint|
      tabs << {
        :name => sprint.name,
        :action => :update_general, :partial => 'sprint',
        :label => sprint.name,
        :sprint => sprint
      }
    end
    tabs
  end

  def render_sprint_tabs(tabs)
    if tabs.any?
      render :partial => 'sprints', :locals => {:tabs => tabs}
    else
      content_tag 'p', l(:label_no_data), :class => "nodata"
    end
  end
end
