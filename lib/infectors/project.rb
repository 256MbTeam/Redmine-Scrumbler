module Scrumbler
  module Infectors
    module Project
      module ClassMethods;end
      
      module InstanceMethods;end
      
      def self.included(receiver)
        receiver.class_eval {
          has_one :scrumbler_project_setting
          has_many :scrumbler_sprints
        }
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end