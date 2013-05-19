require 'json'

module EventSource
    class Event
        attr_reader :name, :entity_id, :data

        def initialize(name, entity)
            @name = name.to_s
            @entity_id = entity.uid
            @data = entity.entity_changes.to_json
        end
    end
end
