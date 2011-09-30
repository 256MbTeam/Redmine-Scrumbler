module Scrumbler
  class Hooks < Redmine::Hook::ViewListener
    def destroy_version(params)
      puts "destroy_version(params)\n"*8
      @version = params[:version]
      ScrumblerSprint.destroy_if_exists(@version.project_id, @version.id)
    end
    
    def create_version(params)
      puts "create_version(params)\n"*8
      @version = params[:version]
      ScrumblerSprint.crate_if_not_exists(@version.project_id, @version.id)
    end
  end
end