module ScrumberSprintsHelper
  def scrumbler_sprint_settings_tabs
    tabs = [{:name => 'trackers', :action => :edit_project, :partial => 'trackers', :label => :label_information_plural},
            {:name => 'issue-statuses', :action => :select_project_modules, :partial => 'issue_statuses', :label => :label_module_plural},
            ]
  end
end
