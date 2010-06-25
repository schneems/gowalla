module Gowalla
  
  class Client
    include HTTParty
    format :json
    base_uri "http://api.gowalla.com"
    headers({'Accept' => 'application/json', "User-Agent" => 'Ruby gem'})
    
        
    attr_reader :username
    
    def initialize(options={})
      api_key = options[:api_key] || Gowalla.api_key
      @username = options[:username] || Gowalla.username
      password = options[:password] || Gowalla.password
      self.class.basic_auth(@username, password) unless @username.nil?
      self.class.headers({'X-Gowalla-API-Key' => api_key }) unless api_key.nil?
    end
    
    def user(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}"))
    end
    
    def events(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/events")).activity
    end
    
    def friends_events
      mashup(self.class.get("/visits/recent")).activity
    end
    
    def friend_requests(user_id=self.username) ## ask gowalla about this one /friendships/request?user_id=1
      mashup(self.class.get("/users/#{user_id}/friend_requests")).friends_needing_approval
    end
    
    def friends(user_id=self.username) ## changed .friends to .users
      mashup(self.class.get("/users/#{user_id}/friends")).users
    end
    
    def items(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/items")).items
    end
    
    def missing_items(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/items/missing")).items
    end
    
    def vaulted_items(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/items/vault")).items
    end
    
    def item(id)
      mashup(self.class.get("/items/#{id}"))
    end
    
    def pins(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/pins"))
    end
    
    def stamps(user_id=self.username, limit=20)
      mashup(self.class.get("/users/#{user_id}/stamps", :query => {:limit => limit})).stamps
    end
    
    def top_spots(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/top_spots")).top_spots
    end
    
    def visited_spots(user_id=self.username)
      mashup(self.class.get("/users/#{user_id}/visited_spots"))
    end
    
    def trip(trip_id)
      mashup(self.class.get("/trips/#{trip_id}"))
    end
    
    def spot(spot_id)
      mashup(self.class.get("/spots/#{spot_id}"))
    end
    
    def spot_events(spot_id)
      mashup(self.class.get("/spots/#{spot_id}/events")).activity
    end
    
    def spot_items(spot_id)
      mashup(self.class.get("/spots/#{spot_id}/items")).items
    end
    
    def list_spots(options={})
      query = format_geo_options(options)
      mashup(self.class.get("/spots", :query => query)).spots
    end
    
    def featured_spots(options={})
      list_spots(options.merge(:featured => 1))
    end
    
    def bookmarked_spots(options={})
      list_spots(options.merge(:bookmarked => 1))
    end
    
    def trips(options={})
      if user_id = options.delete(:user_id)
        options[:user_url] = "/users/#{user_id}"
      end
      query = format_geo_options(options)
      mashup(self.class.get("/trips", :query => query)).trips
    end
    
    def featured_trips(options={})
      trips(options.merge(:context => 'featured'))
    end
    
    def friends_trips(options={})
      trips(options.merge(:context => 'friends'))
    end
    
    def categories
      mashup(self.class.get("/categories")).spot_categories
    end
    
    def category(id)
      mashup(self.class.get("/categories/#{id}"))
    end
    
    def checkin(spot_id, options = {})
      query = format_geo_options(options)
      mashup(self.class.post("/checkins", :body => options, :query => { :spot_id => spot_id }))
    end
    
    private
    
      def format_geo_options(options={})
        options[:lat] = "+#{options[:lat]}" if options[:lat].to_i > 0
        options[:lng] = "+#{options[:lng]}" if options[:lng].to_i > 0
        if options[:sw] && options[:ne]
          options[:order] ||= "checkins_count desc"
        end
        options
      end
    
      def mashup(response)
        case response.code
        when 200
          if response.is_a?(Hash)
            Hashie::Mash.new(response)
          else
            if response.first.is_a?(Hash)
              response.map{|item| Hashie::Mash.new(item)}
            else
              response
            end
          end
        end
      end
    
  end
  
end