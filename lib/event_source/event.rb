require 'json'

module EventSource
    class Event
        attr_reader :name, :entity_id, :data, :created_at

        def initialize(name, entity)
            @name = name.to_s
            @entity_id = entity.uid
            @data = entity.entity_changes.to_json
            @created_at = Time.now
        end
    end
end
