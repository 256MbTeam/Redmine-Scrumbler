ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    project.scrumbler_settings 'scrumbler/settings', :controller => 'scrumbler', :action => :settings
    project.resources :scrumbler_maintrackers
  end

end