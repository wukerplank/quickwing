require 'bunny'
require 'json'

class RootController < ApplicationController

  # The action for our publish form.
  def publish
    channel = client.create_channel
    exchange = channel.fanout("#{ENV['SEARCH_JOB_EXCHANGE_NAME']}", :durable => true)
    channel.queue("foursquare", :auto_delete => true, :durable => false).bind(exchange)
    channel.queue("yelp", :auto_delete => true, :durable => false).bind(exchange)

    # we need to make something non durable!

    if(params[:location].present?)
      message_type = "location"
    else
      message_type = "coordinates"
    end

    exchange.publish({
       :message_type => message_type,
       :term => params[:term].strip,
       :location => params[:location].strip,
       :lat => params[:latitude].strip,
       :lng => params[:longitude].strip,
       :limit => 20,
       :user_uuid => session[:user_uuid],
    }.to_json, :persistent => false)

    client.close

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