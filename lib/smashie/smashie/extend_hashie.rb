## Opening up Hashie::Mash to allow us to string together API calls
## requires calling object to contain connection string, we can use callback_wrapper to achieve this

module Hashie
  class Mash 
    alias :original :method_missing

    ## Catch nil hashie results and send to connection#extend_api to see if method isvalid
    
    ## we also propagate the connection object through the hashie so we can string together methods
    def method_missing(method_name, *args, &blk)      
      result = original(method_name, *args, &blk)
      if result.nil? and self[:connection]
        result = self.connection.extend_api(self, method_name.to_s, *args, &blk) if self.connection.methods.include? "extend_api"
      end
      result = propagate_connection_object(self.connection, result) if self[:connection]
      ensure return result    
    end
    
    
    ## propagate connection object to Connection calls to let us string together methods 
    def propagate_connection_object(connection, result) 
      if result.class.to_s == "Hashie::Mash"
        result[:connection] = connection 
      elsif
        result.class.to_s == "Array"
        result.each do |entry|
          entry[:connection] = connection 
        end
      end
      return result
    end
    
    ## Removes all connection objects from Hash for extra security
    def sanitize_connection_objects!
      self.each do |part|
        if part.class.to_s == "Hashie::Mash" || part.class.to_s == "Array"
          part.sanitize_connection_objects!
        else
          part.connection = nil unless part[:connection].nil?
        end
      end
    end
  
    
  end
end


## Removes all connection objects from Array for extra security
class Array
  def sanitize_connection_objects!
    self.each do |part|
        if part.class.to_s == "Hashie::Mash" || part.class.to_s == "Array"
          part.sanitize_connection_objects!
        else
          part.connection = nil unless part[:connection].nil?
        end
    end
  end
end
