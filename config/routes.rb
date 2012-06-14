  scope 'admin', :as => 'scrumbler_admin' do                                            
    post '/scrumbler/points_field', :as => 'update_points_field', :controller => 'scrumbler_admins', :action => 'update_points_field', :format => false
    put '/scrumbler/points_field', :as => 'update_points_field', :controller => 'scrumbler_admins', :action => 'update_points_field', :format => false
    match '/scrumbler/:tab' => 'scrumbler_admins#index', :as => nil, :format => false
  end    

  match '/scrumbler/admin' => "scrumbler_admins#index"

  match '/projects/:project_id/scrumbler_backlogs/create_issue' => 'scrumbler_backlogs#create_issue', :format => false, :as => 'project_scrumbler_backlogs_new_issue'

  resources :projects do
    resource :scrumbler_backlogs, :only => [:show] do
      member do
        post :update_scrum_points
        post :change_issue_version
        post :select_sprint
        post :create_version
        post :open_sprint 
        post :new_issue
        get  :new_issue
        post :move_issue_priority 
      end
      # could not create into resource block, move out until a better idea
      # match 'create_issue' => 'scrumbler_backlogs#create_issue', :format => false, :as => 'new_issue', :on => :collection
    end
    
    resource "scrumbler", :controller => 'scrumbler' do
      member do
        get '/index' => 'scrumbler#index'
        post :sprint
      end
    end

    resource :scrumbler_settings, :only => [:show] do
      member do
        post :update_trackers 
        post :update_issue_statuses
      end
    end
    match 'scrumbler_settings/:tab' => 'scrumbler_settings#show', :tab => nil, :as => 'scrumbler_settings', :format => false

    resources :scrumbler_sprints do
      member do
        post :update_general
        post :update_trackers
        post :update_issue_statuses
        get :burndown
        post :close_confirm
        get :settings
      end
      get  'settings/:tab' => 'scrumbler_sprints#settings', :tab => 'general', :as => 'settings', :format => false
      post 'issue/:issue_id' => 'scrumbler_sprints#update_issue', :as => 'update_issue'
      post 'issue/:issue_id/change_assignment_to_me' => 'scrumbler_sprints#change_issue_assignment_to_me', :format => false
      post 'issue/:issue_id/drop_issue_assignment' => 'scrumbler_sprints#drop_issue_assignment', :as => 'drop_issue_assignment', :format => false
    end

  end

