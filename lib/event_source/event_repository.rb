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
            sql = 'insert into events (name, entity_id, data, created_at) values ('
            sql += "\n'#{event.name}', '#{event.entity_id}', '#{event.data}', '#{event.created_at}')"

            @db.run(sql)
        end

        def get_events(uid)
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
                String :entity_id
                String :name
                Time :created_at
                String :data
            end
        end
    end
end

