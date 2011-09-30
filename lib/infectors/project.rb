module Scrumbler
  module Infectors
    module Project
      module ClassMethods;end
      
      module InstanceMethods;end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          has_one :scrumbler_project_setting
          has_many :scrumbler_sprints
        }
      end
    end
  end
end