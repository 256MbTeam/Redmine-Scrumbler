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

class ScrumblerSettingsController < ScrumblerAbstractController
  unloadable

  #  before_filter :authorize, :only => [:settings]
  
  def show
  end
  
  def update_maintrackers
    params[:scrumbler_maintrackers] ||= []
    ScrumblerProjectSetting.transaction do
      unless @scrumbler_project_setting.update_attributes(:maintrackers => params[:scrumbler_maintrackers].map(&:to_i))
        flash[:error] = t :error_scrumbler_maintrackers_update
      end
    end
    
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_settings_url(@project)
  end
  
end
