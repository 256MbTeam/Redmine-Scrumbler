module Scrumbler
  module Infectors
    module Version
      module ClassMethods;end

      module InstanceMethods
        def create_sprint
          Redmine::Hook.call_hook(:create_version, :version => self)
        end
        
        def destroy_sprint
          Redmine::Hook.call_hook(:destroy_version, :version => self)
        end
      end
      
      def self.included(receiver)
        receiver.class_eval {
          after_save :create_sprint
          before_destroy :destroy_sprint
        }
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end