namespace :consumer do
  
  desc "Collects data from Yelp!"
  task :yelp => :environment do
    
    api_credentials = {
      :consumer_key    => ENV['YELP_CONSUMER_KEY'],
      :consumer_secret => ENV['YELP_CONSUMER_SECRET'],
      :token           => ENV['YELP_TOKEN'],
      :token_secret    => ENV['YELP_TOKEN_SECRET']
    }
    
    ExternalApiConsumer.new('yelp') do |payload|
      payload['limit'] ||= 10
      
      client = Yelp::Client.new
      
      if payload['message_type']=='location'
        request = Yelp::V2::Search::Request::Location.new({
          :term  => payload['term'], 
          :city  => payload['location'],
          :limit => payload['limit']}.merge(api_credentials)
        )
      elsif payload['message_type']=='coordinates'
        request = Yelp::V2::Search::Request::GeoPoint.new({
          :term      => payload['term'], 
          :latitude  => payload['lat'], 
          :longitude => payload['lng'],
          :limit     => payload['limit']}.merge(api_credentials)
        )
      end
      
      if request
        results = client.search(request)
        
        puts results.inspect
      end
    end
  end
  
end