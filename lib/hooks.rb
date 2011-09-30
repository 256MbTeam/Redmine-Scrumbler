module Scrumbler
  class Hooks < Redmine::Hook::ViewListener
    def destroy_version(params)
      @version = params[:version]
      ScrumblerSprint.destroy_if_exists(@version.project_id, @version.id)
    end
    
    def create_version(params)
      @version = params[:version]
      ScrumblerSprint.crate_if_not_exists(@version.project_id, @version.id)
    end
    
    def enable_module(params)
     
    end
    
    def disable_module(params)
     
    end
  end
end