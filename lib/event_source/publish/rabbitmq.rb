require 'bunny'

module EventSource
    class Publisher
        extend EventSource::MemoizeInstance

        def initialize(options)
            @configured = false

            exchange_name = options[:exchange_name] || 'event_source.events'

            if options[:connection]
                @conn = options[:connection]
                @channel = @conn.create_channel
                @exchange = @channel.fanout(exchange_name)
                @configured = true
            end
        end

        def publish(event)
            return unless @configured
            @exchange.publish(event.to_json)
        end
    end
end
