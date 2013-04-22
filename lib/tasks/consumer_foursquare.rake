namespace :consumer do
  
  desc "Foursuqare Consumer"
  task :foursquare => :environment do

    ExternalApiConsumer.new('foursquare') do |payload, eac|
      payload['limit'] ||= 10

      # Instantiate client
      client = Foursquare2::Client.new(
        :client_id => ENV['FOURSQUARE_CLIENT_ID'],
        :client_secret => ENV['FOURSQUARE_CLIENT_SECRET']
      )

      if payload['message_type'] == 'location'
        results = client.search_venues(
          :near => payload['location'],
          :query => payload['term'],
          :limit => payload['limit']
        )
      elsif payload['message_type'] == 'coordinates'
        results = client.search_venues(
          :ll => "#{payload['lat']},#{payload['lng']}",
          :query => payload['term'],
          :limit => payload['limit']
        )
      end

      if results
        final_results = {
          'source_name' => 'foursquare',
          'businesses' => []
        }

        results.groups[0].items.each do |result|
          businesses = {
            'name'        => result.name,
            'description' => nil,
            'source_url'  => result.canonicalUrl,
            'rating'      => nil
          }
          if result.location.present?
            businesses = businesses.merge({
              'street' => result.location.address,
              'zip'    => result.location.postal_code,
              'city'   => result.location.city,
              'lat'    => result.location.lat,
              'lng'    => result.location.lng
            })
          else
            businesses = businesses.merge({'street'=>'', 'zip'=>'', 'city'=>'', 'lat'=>'', 'lng'=>''})
          end
            
          final_results['businesses'] << businesses
        end

        eac.send_result(payload['user_uuid'], final_results.to_json)
      end
    end
  end
end