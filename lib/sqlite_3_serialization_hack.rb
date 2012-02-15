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


# Override binary_to_string SQLite adapter method for supporting hash serialization
if ActiveRecord::ConnectionAdapters.const_defined?('SQLite3Adapter') && 
   ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) then
   ActiveRecord::ConnectionAdapters::SQLiteColumn.module_eval {
        class << self
          alias_method :old_binary_to_string, :binary_to_string
            def binary_to_string(value)
              return value if value.instance_of? HashWithIndifferentAccess
              old_binary_to_string(value)
            end
        end
      }
end
