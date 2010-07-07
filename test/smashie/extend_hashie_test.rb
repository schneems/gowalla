
require '../helper'


class ExtendedHashie < Test::Unit::TestCase
  
  
  context "When using the Gowalla API" do
    setup do
      @client = Gowalla::Client.new(:username => 'pengwynn', :password => '0U812', :api_key => 'gowallawallabingbang')
    end
    
    
    context "using the extended hashie" do
      should "spot.get_checkins should issue get all checkins from a URL" do
        stub_get("http://pengwynn:0U812@api.gowalla.com/spots?lat=%2B33.237593417&lng=-96.960559033&radius=50", "spots_2010_july_5.json")
        spots = @client.list_spots(:lat => 33.237593417, :lng => -96.960559033, :radius => 50)
        stub_get("http://pengwynn:0U812@api.gowalla.com/checkins?spot_id=833559", "checkins_2010_july_5.json")        
        spots.first.get_checkins.events.count.should == 100
      end
      
      should "spot.user.get should get a user" do
        stub_get('http://pengwynn:0U812@api.gowalla.com/spots/18568', 'spot.json')
        spot = @client.spot(18568)
        stub_get("http://pengwynn:0U812@api.gowalla.com/users/2", "user_with_id_2.json")
        spot.last_checkins.first.user.get.url.should == spot.last_checkins.first.user.url
      end   
      
      should "spot.user.get should get a user" do
        stub_get('http://pengwynn:0U812@api.gowalla.com/spots/18568', 'spot.json')
        spot = @client.spot(18568)
        stub_get("http://pengwynn:0U812@api.gowalla.com/users/2", "user_with_id_2.json")
        spot.last_checkins.first.user.get.url.should == spot.last_checkins.first.user.url
      end
          
    end
  end
end

