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

class ScrumblerController < ScrumblerAbstractController
  unloadable

  #  before_filter :authorize, :only => [:settings]
  
  def index
    if(params[:show_all] == "true")
      @scrumbler_sprints = @project.scrumbler_sprints
    else
      @scrumbler_sprints = @project.scrumbler_sprints.opened
    end
    
    @scrumbler_sprint = ScrumblerSprint.find(params[:scrumbler_sprint_id]) rescue @scrumbler_sprints.last
    @show_all = params[:show_all]
  end
    
  def sprint
    @sprint = @project.scrumbler_sprints.find(params[:sprint_id])
    render :update do |page|
      page.replace_html 'scrumbler_sprint', :partial => 'sprint', :object => @sprint
    end
  end
  
end
