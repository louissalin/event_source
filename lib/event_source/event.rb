module EventSource
    class Event
        attr_reader :entity_id

        def initialize(entity)
            @entity_id = entity.uid
        end
    end
end
