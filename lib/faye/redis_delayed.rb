require 'faye/redis'

module Faye
  class RedisDelayed < Faye::Redis
    DEFAULT_EXPIRE = 60 # default expiration timeout for awaiting messages

    def subscribe(client_id, channel, &callback)
      super
      publish_awaiting_messages(channel)
    end

    def publish_awaiting_messages(channel)
      # fetch awaiting messages from redis and publish them
      @redis.lpop(@ns + "/channels#{channel}/awaiting_messages") do |json_message|
        if json_message
          message = MultiJson.load(json_message)
          publish(message, [message["channel"]], json_message)
          publish_awaiting_messages(channel)
        end
      end
    end

    def publish(message, channels, json_message = nil)
      init
      @server.debug 'Publishing message ?', message

      json_message ||= MultiJson.dump(message)
      channels     = Channel.expand(message['channel'])
      keys         = channels.map { |c| @ns + "/channels#{c}" }

      @redis.sunion(*keys) do |clients|
        if clients.empty? && delay_channel?(message["channel"])
          key = @ns + "/channels#{message["channel"]}/awaiting_messages"
          # store message in redis
          @redis.rpush(key, json_message)
          # Set expiration time to one minute
          @redis.expire(key, @options[:expire] || DEFAULT_EXPIRE)
        end


        clients.each do |client_id|
          queue = @ns + "/clients/#{client_id}/messages"

          @server.debug 'Queueing for client ?: ?', client_id, message
          @redis.rpush(queue, json_message)
          @redis.publish(@message_channel, client_id)

          client_exists(client_id) do |exists|
            @redis.del(queue) unless exists
          end
        end
      end

      @server.trigger(:publish, message['clientId'], message['channel'], message['data'])
    end

    private

    def delay_channels
      @delay_channels ||= Array(@options[:delay_channels]).flatten
    end

    # returns true if this channel should be delayed.  The default is
    # yes, unless :delay_channels is set in the engine options

    def delay_channel?(channel)
      delay_channels.empty? || delay_channels.any? { |pattern| pattern === channel }
    end
  end
end
