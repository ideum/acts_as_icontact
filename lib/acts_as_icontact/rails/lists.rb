module ActsAsIcontact
  module Rails
    module InstanceMethods
      module Lists
        def icontact_subscribe(list)
          find_contact_by_identity.subscribe(list)
        end

        def icontact_unsubscribe(list)
          find_contact_by_identity.unsubscribe(list)
        end
      end
    end

    module ClassMethods
      module Lists
        def extended(base)
        base.class_eval do 
        end
        end
 
        # The lists that each new contact will be subscribed to upon creation.  Set by the :list and :lists 
        # options to acts_as_icontact.
        def icontact_default_lists
          @icontact_default_lists
        end
        
        protected
        
        # Builds an array of any lists in the :list or :lists parameter.
        def set_default_lists(list, lists)
          # Combines :list and :lists parameters into one array
          @icontact_default_lists = []
          @icontact_default_lists << list if list
          @icontact_default_lists += lists if lists
        end

      end
    end
  end
end
