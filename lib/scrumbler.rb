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

module Scrumbler
  MODULE_NAME = "redmine_scrumbler"
  module Infectors
    def self.integration_module_for(project)
      if project.module_enabled?(Scrumbler::MODULE_NAME)
      yield
      end
    end
  end

  module Hooks
    class AdminMenuHooks < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = { })
        stylesheet_link_tag 'scrumbler.css', :plugin => :redmine_scrumbler, :media => 'screen'
      end
    end
  end

  module Migration
    def self.migration_exist?(*names)
      all_migrations = ActiveRecord::Base::connection.select_values("select version from schema_migrations")
      all_migrations.select {|migration_name|
        names.include?(migration_name)
        }.count == names.count
    end
  end

end