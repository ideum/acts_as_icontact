require 'enumerator'

module ActsAsIcontact
  class ResourceCollection
    include Enumerable 

    attr_reader :total, :retrieved, :offset, :collection_name
    
    def initialize(klass, collection, options={})
      @klass = klass
      @forwardTo = options.delete(:forwardTo)
      @parent = options.delete(:parent)
      
      @collection_name = klass.collection_name
      @collection = collection[collection_name]
      # Get number of elements
      @retrieved = @collection.size
      @total = collection["total"]
      @offset = collection["offset"]
    end
    
    def each
      counter = 0
      while counter < @retrieved
        yielder.yield resource(@collection[counter])
        counter += 1
      end
    end

    def [](index)
      resource(@collection[index]) if @collection[index]
    end
    
    # Calls "next" to kick off the enumerator.  This is more in line with what users would expect.
    def first
      self.rewind
      self.next
    end
    
    # Returns a nice formatted string for command line use.
    def inspect
      if offset.to_i > 0
        "#{retrieved} out of #{total} #{collection_name} (offset #{offset})"
      elsif retrieved != total
        "#{retrieved} out of #{total} #{collection_name}"
      else
        "#{total} #{collection_name}"
      end
      
    end
    
    private 
    def resource(properties)
      # If this is a subresource, include the parent object as a property
      properties.merge!(:parent => @parent) if @parent
      
      # "Forward to" is used to link Contacts and Lists via Subscriptions in a has_many :through
      if @forwardTo
        id = @forwardTo.primary_key
        @forwardTo.find(properties[id])
      else
        @klass.new(properties)
      end
    end
  end
end
