

require '../helper'


class CallbackWrapperTest < Test::Unit::TestCase
  
  
  context "When using the Gowalla API" do
    setup do
      @client = Gowalla::Client.new(:username => 'pengwynn', :password => '0U812', :api_key => 'gowallawallabingbang')
    end
    
    
    context "and generating a hashie" do
      should "append the connection object to the hash" do
        stub_get("http://pengwynn:0U812@api.gowalla.com/spots?lat=%2B33.237593417&lng=-96.960559033&radius=50", "spots.json")
        spots = @client.list_spots(:lat => 33.237593417, :lng => -96.960559033, :radius => 50)
        spots.first.connection.should == @client
      end
      
     should "retrieve information about a specific user" do
       stub_get('http://pengwynn:0U812@api.gowalla.com/users/sco', 'user.json')
       user = @client.user('sco')
       user.connection.should == @client
     end
     
     should "retrieve information about a specific item" do
       stub_get('http://pengwynn:0U812@api.gowalla.com/items/607583', 'item.json')
       item = @client.item(607583)
       item.connection.should == @client
     end      
    end
    
    
    
    
  end

  context "When Including CallbackWrapper in a class" do
    setup do
      begin
        Example
      rescue
        class Example 
          include CallbackWrapper 
          def foo(variable) ;return variable ;end
        end
      end
    end
    
    context "including callback wrapper to a class auto adds methods" do
      should "add CLASS method before_callback" do 
        Example.methods.include?("before_callback") 
      end
      
      should "add CLASS method after_callback" do 
        Example.methods.include?("after_callback") 
      end
      
      should "add INSTANCE method after_callback" do 
        instance = Example.new
        instance.methods.include?("before_callback")
      end
      
      should "add INSTANCE method before" do 
        instance = Example.new
        instance.methods.include?("before_callback") 
      end
      
      
      should "add before_callback should be capeable of modifing arguments in place" do 
        Example.class_eval %{
          def before_callback(*args, &block)
             args.first.replace  args.first + "_before_callback_worked"
          end
          def after_callback(result,*args, &block)
          end
        }
        Example.new.foo("hello").should == "hello_before_callback_worked"
      end
      
      should "add INSTANCE method beforeaa" do 
        Example.class_eval %{
          def before_callback(*args, &block)
          end
          def after_callback(result,*args, &block)
            result.replace result + "bar"
          end
        }
        Example.new.foo("foo").should == "foobar"

      end
      

      
    end
    
    context "including callback wrapper lets us modify arguements before run by the origional method" do
      

    end
    
    


  end
end
