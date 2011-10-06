module ScrumberSprintsHelper
  def scrumbler_sprint_settings_tabs
    tabs = [{:name => 'trackers', :action => :update_trackers, :partial => 'trackers', :label => :label_tracker_plural},
            {:name => 'issue_statuses', :action => :update_issue_statuses, :partial => 'issue_statuses', :label => :label_issue_statuses},
            ]
  end
end
