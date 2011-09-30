ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    project.resource :scrumbler_settings, :member => {
      :update_maintrackers => :post
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler'
  end

end