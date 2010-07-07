##  Smashie is designed to expand a Hashie::Mash-ed API to produce more ruby like and fully functioning api's
##  add smashie to the class you would like to extend
##  
##  include Smashie
##  
##  Any methods that return a Hashie::Mash automatically get the connection object appended to the return
##  
##  the class where smashie is included can expand its api, by defining extend_api
##  
##      def extend_api(caller, method_name, * args, &blk) 
##        if method_name.to_s  =~ /^get.*/    
##          if method_name.to_s == "get"
##            method_name = "url"
##          else
##            method_name = method_name.to_s.gsub( "get_", "") + "_url" 
##          end        
##          data_url = caller.send method_name
##          return connection.get(data_url).body
##        else
##          return nil
##        end
##      end
##      
##  Where extend_api will be called any time a Hashie::Mash object calls a method that doesn't exist and is not a valid
##  hash key return a 


directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'smashie', 'callbackwrapper')
require File.join(directory, 'smashie', 'extend_hashie')




module Smashie 
  def self.included(klass)
    klass.class_eval %{
      include CallbackWrapper
      def after_callback(results,*args, &block)
        if results.class.to_s == "Array"
          results.each do |result|
            add_connection(result)
          end
        else
            add_connection(results)
        end
      end


      def add_connection(result)
        if result.class.to_s == "Hashie::Mash"    
          result.connection = self
          result.replace result
        end
      end            
    }    
  end
end