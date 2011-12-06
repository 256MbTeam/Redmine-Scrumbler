class ScrumblerCustomField < IssueCustomField
  unloadable
  
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
      ScrumblerCustomField.create :name => ScrumPointsName,
        :field_format => "list", 
        :possible_values => %w(? 0 1/2 1 2 3 5 8 13 20 40 100),
        :is_required => true,
        :is_filter => true,
        :default_value => "?",
        :trackers => Tracker.all
    end
  end
  
end