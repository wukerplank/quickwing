require 'bunny'
require 'json'

class RootController < ApplicationController

  # The action for our publish form.
  def publish
    # Send the message from the form's input box to the "messages"
    # queue, via the nameless exchange.  The name of the queue to
    # publish to is specified in the routing key.

    channel = bunny_client.create_channel
    queue = channel.queue("messages")
    exchange = channel.default_exchange
    exchange.publish params[:message],
                     :routing_key => queue.name

    # Notify the user that we published.
    flash[:published] = true
    redirect_to root_path
  end

  def get
    # Synchronously get a message from the queue

    msg = bunny_client.queue("messages").pop
    # Show the user what we got
    #delivery_info, metadata, payload = bunny_client.queue("messages").pop
    logger.info(msg.inspect)
    flash[:got] = msg[2]
    redirect_to root_path
  end

  private
  def rabbit_url
    "amqp://#{ENV['RABBIT_MQ_USER']}:#{ENV['RABBIT_MQ_PASSWORD']}@#{ENV['RABBIT_MQ_HOST']}:#{ENV['RABBIT_MQ_PORT']}"
  end

  def bunny_client
    @client ||= begin
      c = Bunny.new(rabbit_url)
      c.start
      c
    end
  end

end
