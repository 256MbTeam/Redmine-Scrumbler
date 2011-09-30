module Scrumbler
  class Hooks < Redmine::Hook::ViewListener
    def destroy_version(params)
      @version = params[:version]
      ScrumblerSprint.destroy_if_exists(@version.project_id, @version.id)
    end
    
    def create_version(params)
      @version = params[:version]
      ScrumblerSprint.create_if_not_exists(@version.project_id, @version.id)
    end
    
    def enable_module(params)
      @module = params[:module]
      ScrumblerSprint.create_sprints_for_project(@module.project_id)
    end
    
    def disable_module(params)
      @module = params[:module]
      ScrumblerSprint.destroy_all_in_project(@module.project_id)
    end
  end
end