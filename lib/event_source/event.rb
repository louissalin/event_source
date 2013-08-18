require 'active_support/inflector'
require 'json'

module EventSource
    class Event
        attr_reader :name, :entity_type, :entity_id, :data, :created_at

        class << self
            def build_from_data(data)
                event = self.new
                event.send(:new_from_data, data)
                event
            end

            def create(name, entity, args)
                event = self.new
                event.send(:new_from_entity, name, entity, args)
                event
            end
        end

        def get_args
            JSON.parse(data)
        end

        def save
            raise CannotSaveRebuiltEvent if @is_rebuilt
            EventSource::EventRepository.current.save(self)
        end

        def to_json
            {
                name: @name,
                entity_id: @entity_id,
                data: @data,
                created_at: @created_at,
                entity_type: @entity_type
            }.to_json
        end

        private

        def new_from_entity(name, entity, args)
            @name = name.to_s
            @entity_id = entity.uid
            @data = args.to_json
            @created_at = Time.now
            @entity_type = entity.class.to_s.underscore

            @is_rebuilt = false
        end

        def new_from_data(data)
            @name = data[:name]
            @entity_id = data[:entity_id]
            @data = data[:data]
            @created_at = data[:created_at]
            @entity_type = data[:entity_type]

            @is_rebuilt = true
        end
    end
end
