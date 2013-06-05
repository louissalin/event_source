require 'sequel'

module EventSource
    class EventRepository
        attr_reader :db

        class << self
            def current
                @@instance ||= self.new(in_memory: true)
            end

            def create(options)
                @@instance = self.new(options)
            end
        end

        def save(event)
            count = @db[:events].where(entity_type: event.entity_type, entity_id: event.entity_id).count

            raise InvalidEntityID if count > 0
            @db[:events].insert(name: event.name, entity_type: event.entity_type,
                                entity_id: event.entity_id, data: event.data,
                                created_at: event.created_at)
        end

        def get_events(type, uid)
            []
        end

        private

        def initialize(options)
            if options[:in_memory] 
                @db = Sequel.sqlite
                init_in_memory_schema
            end
        end

        def init_in_memory_schema
            @db.create_table :events do
                primary_key :id
                String :name
                String :entity_id
                String :entity_type
                Time :created_at
                String :data
            end
        end
    end
end

