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
  
  helper ScrumberSettingsHelper
  #  before_filter :authorize, :only => [:settings]
  
  def show
    @issue_statuses = IssueStatus.all
  end
  
  def update_trackers
    update_setting :trackers, :error_scrumbler_trackers_update
  end
  
  def update_issue_statuses
    update_setting :issue_statuses, :error_scrumbler_issue_statuses_update
  end
  
  
  private
  def update_setting(setting_name, error_message_link)
    params[:scrumbler_project_setting][setting_name] ||= {}
    @scrumbler_project_setting.settings[setting_name] = {}

    params[:scrumbler_project_setting][setting_name].each do |key, value|
      @scrumbler_project_setting.settings[setting_name][key] = value if value[:use]
    end
    
    flash[:error] = t error_message_link unless @scrumbler_project_setting.save
    flash[:notice] = t :notice_successful_update unless flash[:error]
    redirect_to project_scrumbler_settings_url(@project, setting_name)
  end
  
end
