ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    project.resource :scrumbler_settings, :member => {
      :update_maintrackers => :post
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler'
    
    project.sprint 'sprint/:sprint_id', :controller => 'scrumbler', :action => :sprint, :method => :post
  end

  
end