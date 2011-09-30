module Scrumbler
  module Infectors
    module EnabledModule
      module ClassMethods;end

      module InstanceMethods
        def enable_module
          Redmine::Hook.call_hook(:enable_module, :module => self)
        end
        
        def disable_module
          Redmine::Hook.call_hook(:disable_module, :module => self)
        end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval {
          after_create :enable_module
          before_destroy :disable_module
        }
      end
    end
  end
end

