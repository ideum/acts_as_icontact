module ActsAsIcontact
  module Rails
    module Callbacks
      
      protected
      def icontact_custom_fields_mapped?
        self.class.send(:set_custom_field_mappings)
      end

      def icontact_action_permitted?
        send(self.class.icontact_conditional_save_callback) if self.class.icontact_conditional_save_callback
      end

      # Called after a new record has been saved.  Creates a new contact in iContact.
      def icontact_after_create
        return unless icontact_action_permitted? and icontact_custom_fields_mapped?

        logger.debug "ActsAsIcontact creating contact for Rails ID: #{id}"
        c = ActsAsIcontact::Contact.new
        update_contact_from_rails_fields(c)
        if attempt_contact_save(c)
          update_rails_fields_from_contact(c)
        end
      end

      # Called after an existing record has been updated.  Updates an existing contact in iContact if one
      # can be found; otherwise creates a new one.
      def icontact_after_update
	return unless icontact_custom_fields_mapped?

        if icontact_action_permitted?
          self.class.send(:set_custom_field_mappings)
          unless @icontact_in_progress # Avoid callback loops
            c = (find_contact_by_identity or ActsAsIcontact::Contact.new)
            update_contact_from_rails_fields(c)
            if attempt_contact_save(c)
              update_rails_fields_from_contact(c)
            end
          end
        else
          # Unsubscribe contact from lists?
        end
      end
      
      private
      def find_contact_by_identity
        self.class.send(:set_custom_field_mappings)
        im = self.class.icontact_identity_map
        if (im[1] == :contactId)
          ActsAsIcontact::Contact.find(self.send(im[0]))
        elsif (im[0] == :id)
          ActsAsIcontact::Contact.find(im[1] => id)
        else
          ActsAsIcontact::Contact.find(:email => self.send(im[0]))
        end
      rescue ActsAsIcontact::QueryError
        nil
      end
     
      def update_rails_fields_from_contact(contact)
        @icontact_in_progress = true
        modified_record = false

        self.class.icontact_mappings.each do |rails, iContact|
          unless (value = contact.send(iContact)).blank?
            if self.send(rails.to_s) != value
              r = (rails.to_s + '=').to_sym   # Blah. This feels like it should be easier.
              self.send(r, value)
              modified_record = true
            end
          end
        end
        self.save

        if modified_record
          # Subscribe the contact to any lists
          self.class.icontact_default_lists.each do |list|
            contact.subscribe(list)
          end
        end

        @icontact_in_progress = false  # Very primitive loop prevention
      end
 
      def update_contact_from_rails_fields(contact)
        self.class.icontact_mappings.each do |rails, iContact|
          if (value = self.send(rails))
            ic = (iContact.to_s + '=').to_sym   # Blah. This feels like it should be easier.
            contact.send(ic, value)
          end
        end
      end
      
      def attempt_contact_save(contact)
        if self.class.icontact_exception_on_failure
          contact.save!
          logger.info "ActsAsIcontact contact created. Rails ID: #{id}; iContact ID: #{contact.id}"
          true
        else
          if contact.save
            logger.info "ActsAsIcontact contact created. Rails ID: #{id}; iContact ID: #{contact.id}"
            true
          else
            logger.warn "ActsAsIcontact contact creation failed! iContact says: #{contact.error}"
            false
          end
        end
      end
        
    end
  end
end
