# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.clear_active_connections!

def enable_module_for(project)
  project.enable_module!(:redmine_scrumbler)
end

def assign_permissions(role)
  manager_role = role
  manager_role.permissions << :scrumbler
  manager_role.permissions << :scrumbler_backlog
  manager_role.permissions << :scrumbler_settings
  manager_role.save
end