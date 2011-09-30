ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    project.scrumbler_settings 'scrumbler/settings', :controller => 'scrumbler', :action => :settings

  end

end