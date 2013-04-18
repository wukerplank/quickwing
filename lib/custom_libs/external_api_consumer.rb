class ExternalApiConsumer
  def initialize (queue_name, &block)
    @queue_name = queue_name

    @client = Bunny.new("amqp://#{ENV['RABBIT_MQ_USER']}:#{ENV['RABBIT_MQ_PASSWORD']}@#{ENV['RABBIT_MQ_HOST']}:#{ENV['RABBIT_MQ_PORT']}")
    @client.start

    @channel  = @client.create_channel
    @exchange = @channel.fanout(ENV['SEARCH_JOB_EXCHANGE_NAME'])
    
    queue = @channel.queue(@queue_name, :auto_delete=>true).bind(@exchange).subscribe do |delivery_info, metadata, payload|
      json = JSON.parse(payload)
      
      puts "received: #{json.inspect}"
      
      yield json
    end

    loop do
      # wait until this process gets killed
    end
  
    @client.close
  end
end
