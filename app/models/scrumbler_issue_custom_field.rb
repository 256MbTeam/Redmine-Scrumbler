class ScrumblerIssueCustomField < IssueCustomField
  unloadable
  
  def type
    "IssueCustomField"
  end
  
  def find_value_by_issue(issue)
    CustomValue.first(:conditions => {
      :customized_id => issue.id,
      :custom_field_id => self.id,
      :customized_type => issue.to_s
      })
  end
  
  def find_all_values
    CustomValue.first(:conditions => {
      :custom_field_id => self.id
      })
  end
  
  class << self
  
    ScrumPointsName = "Scrum Points"
    
    def points
      first(:conditions => {:name => ScrumPointsName}) || create_points
    end
  
    def customized_class
      Issue
    end
  
    private
    def create_points
      create :name => ScrumPointsName,
        :field_format => "list", 
        :possible_values => %w(? 0 0.5 1 2 3 5 8 13 20 40 100),
        :is_required => true,
        :is_filter => true,
        :default_value => "?",
        :trackers => Tracker.all
    end
  end
  
end