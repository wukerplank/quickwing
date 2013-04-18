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

      results_json = results.to_json

      eac.send_result(payload['user_uuid'], results_json)
    end
  end
end