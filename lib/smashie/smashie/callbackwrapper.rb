## CallbackWrapper adds a before_callback() method before each method called and an after_callback() method after 
## use CallbackWrapper to modify arguements going into methods or modify results coming out of methods


## lots of class_eval's to be backwards compatable with ruby 1.8, 


module CallbackWrapper 
  def self.included(klass)
    klass.const_set(:METHOD_HASH, {})
    suppress_tracing do 
      klass.instance_methods(false).each do |method|    
        wrap_method(klass, method.to_sym)
      end
          ## add class macros [self.before_callback, self.after_callback], 
          ## add instance methods to override [ before_callback, after_callback]
      klass.class_eval %{
        def self.before_callback(method_name)
          self.class_eval %{ alias before_callback \#{method_name} }
        end
        def self.after_callback(method_name)
          self.class_eval %{ alias after_callback \#{method_name} }
        end
        def before_callback(*args, &block)
        end
        def after_callback(result, *args, &block)
        end
      } 
    end 
      
    def klass.method_added(name)    
      return if @_adding_a_method
      @_adding_a_method = true
      CallbackWrapper.wrap_method(self, name) 
      @_adding_a_method = false
    end
  end

  def self.suppress_tracing
    Thread.current[:'suppress tracing'] = true
    yield
  ensure
    Thread.current[:'suppress tracing'] = false
  end

  def self.ok_to_trace?
    !Thread.current[:'suppress tracing']
  end      
  
  def self.wrap_method(klass, name)
    method_hash = klass.const_get(:METHOD_HASH) || fail("No method hash")
    method_hash[name] = klass.instance_method(name)
    klass.class_eval %{
      def #{name}(*args, &block)  
        if CallbackWrapper.ok_to_trace?
          CallbackWrapper.suppress_tracing do
            self.before_callback(*args, &block)
          end
        end
        result = METHOD_HASH[:#{name}].bind(self).call(*args, &block)
        if CallbackWrapper.ok_to_trace?
            CallbackWrapper.suppress_tracing do
              self.after_callback(result, *args, &block)
           end
        end
        result
      end
     }
  end
end


## Inspiration from Dave Thomas' Series Metaprogramming Ruby