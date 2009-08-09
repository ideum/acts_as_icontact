module ActsAsIcontact
  class Contact < Resource
    
    # Email is required
    def self.required_on_create
      super << 'email'
    end
    
    # Defaults to status=total to return contacts on or off lists
    def self.default_options
      super.merge(:status=>:total)
    end
   
    # Returns the lists to which this contact is subscribed (via the Subscription class).
    def lists
      @lists ||= ActsAsIcontact::Subscription.lists(:contactId => id)
    end
    
    # Creates a new subscription for the contact to the specified list
    def subscribe(list)
      l = ActsAsIcontact::List.find(list)
      s = ActsAsIcontact::Subscription.new(:contactId => id, :listId => l.id)
      s.save
    end
    
    # Returns a collection of ContactHistory resources for this contact.  The usual iContact search options (limit, offset, search terms, etc.) can be passed.
    def history(options={})
      ActsAsIcontact::ContactHistory.scoped_find(self, options)
    end
  end
end