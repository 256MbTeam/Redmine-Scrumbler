ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |project|
    
    project.resource :scrumbler_backlogs, :member=>{
      :update_scrum_points => :post,
      :change_issue_version => :post
    },:prefix => '/projects/:project_id/scrumbler_backlogs'
    
    project.resource :scrumbler_settings, :member => {
      :update_sprints => :post,
      :update_trackers => :post,
      :update_issue_statuses => :post
      
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler'
    
    project.scrumbler_settings 'scrumbler_settings/:tab', :tab => nil , :controller => :scrumbler_settings, :action => :show
    
    project.resources :scrumbler_sprints, :member => {
      :update_general => :post,
      :update_trackers => :post,
      :update_issue_statuses => :post,
    } do |sprint|
      sprint.settings     'settings/:tab', :tab => nil,
        :path_prefix => '/projects/:project_id/scrumbler_sprints/:id',
        :controller => :scrumbler_sprints, :action => :settings, :method => :get
      sprint.update_issue 'issue/:issue_id', :path_prefix => '/projects/:project_id/scrumbler_sprints/:id',
        :controller => :scrumbler_sprints, :action => :update_issue, :method => :post

      sprint.change_issue_assignment_to_me 'issue/:issue_id/change_assignment_to_me', :path_prefix => '/projects/:project_id/scrumbler_sprints/:id',
        :controller => :scrumbler_sprints, :action => :change_issue_assignment_to_me, :method => :post
      sprint.drop_issue_assignment 'issue/:issue_id/drop_issue_assignment', :path_prefix => '/projects/:project_id/scrumbler_sprints/:id',
        :controller => :scrumbler_sprints, :action => :drop_issue_assignment, :method => :post
    end
    
    project.sprint 'sprint/:sprint_id', :controller => 'scrumbler', :action => :sprint, :method => :post
  end

  
end