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

Dir[File.join(File.dirname(__FILE__), "infectors", "*.rb")].each{|file| 
  require_dependency file;
  infected_name = File.basename(file, ".rb").classify
  puts "Infected #{infected_name} with #{file} "
  _module = Scrumbler::Infectors.const_get(infected_name)
  _class = Kernel.const_get(infected_name)
  _class.send(:include, _module) unless _class.included_modules.include? _module
}