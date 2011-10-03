ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    project.resource :scrumbler_settings, :member => {
      :update_maintrackers => :post,
      :update_issue_statuses => :post
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler'
    
    project.resources :scrumbler_sprints, :member => {
      :settings => :get,
      :update_trackers => :post
    }
    
    project.sprint 'sprint/:sprint_id', :controller => 'scrumbler', :action => :sprint, :method => :post
  end

  
end