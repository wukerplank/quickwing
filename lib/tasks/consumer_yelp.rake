namespace :consumer do
  
  desc "Collects data from Yelp!"
  task :yelp => :environment do
    
    api_credentials = {
      :consumer_key    => ENV['YELP_CONSUMER_KEY'],
      :consumer_secret => ENV['YELP_CONSUMER_SECRET'],
      :token           => ENV['YELP_TOKEN'],
      :token_secret    => ENV['YELP_TOKEN_SECRET']
    }
    
    ExternalApiConsumer.new('yelp') do |payload, eac|
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
        
        final_results = {
          'source_name' => 'yelp',
          'businesses'  => []
        }
        
        results['businesses'].each do |result|
          final_result = {
            'name'        => result['name'],
            'description' => (result['snippet_text'] || ''),
            'source_url'  => result['url'],
            'rating'      => result['rating']
          }
          if result['location'].present?
            final_result = final_result.merge({
              'street' => result['location']['display_address'][0],
              'zip'    => result['location']['postal_code'],
              'city'   => result['location']['city'],
              'lat'    => result['location']['coordinate']['latitude'],
              'lng'    => result['location']['coordinate']['longitude']
            })
          else
            final_result = final_result.merge({'street'=>'', 'zip'=>'', 'city'=>'', 'lat'=>'', 'lng'=>''})
          end
          
          final_results['businesses'] << final_result
        end
        
        eac.send_result(payload['user_uuid'], final_results.to_json)
      end
    end
  end
  
end