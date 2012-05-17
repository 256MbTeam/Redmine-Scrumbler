ActionController::Routing::Routes.draw do |map|
  
  map.with_options :controller => 'scrumbler_admins' do |admin|
    admin.scrumbler_admin_update_points_field "/admin/scrumbler/points_field", :action => :update_points_field, :conditions => { :method => :post }
    admin.connect "/admin/scrumbler/:tab", :tab => nil
  end
  map.resources :projects do |project|
    
    project.resource :scrumbler_backlogs, :member => {
      :update_scrum_points => :post,
      :change_issue_version => :post,
      :select_sprint => :post,
      :create_version => :post,
      :open_sprint => :post,
      :new_issue => :get,
      :new_issue => :post,
      :move_issue_priority => :post
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler_backlogs' do |backlog|
      
      backlog.new_issue  'create_issue', :controller => :scrumbler_backlogs, :action => :create_issue
    end
    
    project.resource "scrumbler", :controller => :scrumbler, :member=>{
      :index=>:get,
      :sprint=>:post
    }, :prefix => '/projects/:project_id/scrumbler'
    
    project.resource :scrumbler_settings, :member => {
      :update_trackers => :post,
      :update_issue_statuses => :post
    }, :only => [:show], :prefix => '/projects/:project_id/scrumbler_settings'
    
    project.scrumbler_settings 'scrumbler_settings/:tab', :tab => nil , :controller => :scrumbler_settings, :action => :show
    
    project.resources :scrumbler_sprints, :member => {
      :update_general => :post,
      :update_trackers => :post,
      :update_issue_statuses => :post,
      :burndown => :get,
      :close_confirm => :post,
      :settings => :get
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
    
    
  end

  
end