module ActsAsIcontact
  module Rails
    module ClassMethods
      module ConditionalSave
        
        # The lists that each new contact will be subscribed to upon creation.  Set by the :list and :lists 
        # options to acts_as_icontact.
        def icontact_conditional_save_callback
          @icontact_conditional_save_callback
        end
        
        protected
        # Builds an array of any lists in the :list or :lists parameter.
        def set_conditional_save_callback(callback)
          # Combines :list and :lists parameters into one array
          @icontact_conditional_save_callback = callback
        end

      end
    end
  end
end
