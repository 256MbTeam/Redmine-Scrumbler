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
class ScrumblerAdminsController < ApplicationController
  unloadable
  layout 'admin'

  helper :scrumbler_admins
  include ScrumblerAdminsHelper

  before_filter :require_admin

  helper :scrumbler
  
  def index
    @points_field = ScrumblerIssueCustomField.points
    @tab = params[:tab] || 'points_field'
  end


  def update_points_field
    @points_field = ScrumblerIssueCustomField.points
    if request.post? && @points_field.update_attributes(params[:points_field])
      flash[:notice] = l(:notice_successful_update)
    end
    render :action => "index", :tab => "points_field"
  end

end
