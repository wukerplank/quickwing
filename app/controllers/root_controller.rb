require 'bunny'
require 'json'

class RootController < ApplicationController

  # The action for our publish form.
  def publish
    # Send the message from the form's input box to the "messages"
    # queue, via the nameless exchange.  The name of the queue to
    # publish to is specified in the routing key.

    channel = client.create_channel
    exchange = channel.fanout("#{ENV['SEARCH_JOB_EXCHANGE_NAME']}")
    four = channel.queue("foursquare", :auto_delete => true).bind(exchange)
    yelp = channel.queue("yelp", :auto_delete => true).bind(exchange)

    # we need to make something non durable!

    if(params[:location].present?)
      message_type = "location"
    else
      message_type = "coordinates"
    end

    exchange.publish({
                         :message_type => message_type,
                         :term => params[:term],
                         :location => params[:location],
                         :lat => params[:latitude],
                         :lng => params[:longitude],
                         :limit => 20,
                     }.to_json)

    # Notify the user that we published.
    flash[:published] = true
    redirect_to root_path
  end

  private
  def amqp_url
    "amqp://#{ENV['RABBIT_MQ_USER']}:#{ENV['RABBIT_MQ_PASSWORD']}@#{ENV['RABBIT_MQ_HOST']}:#{ENV['RABBIT_MQ_PORT']}"
  end

  def client
    unless @client
      c = Bunny.new(amqp_url)
      c.start
      @client = c
    end
    @client
  end

  def exchange
    @exchange ||= client.exchange("#{ENV['SEARCH_JOB_EXCHANGE_NAME']}")
  end

end