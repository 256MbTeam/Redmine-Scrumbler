module Scrumbler
  module Infectors
    module VersionsController
      module ClassMethods
      
      end
      
      module InstanceMethods
        def create_with_hook
          value = create_without_hook
          #         TODO
          return value
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          alias_method_chain :create, :hook
        end
      end
    end
  end
end