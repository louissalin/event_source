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


#describe EventSource::EventRepository do
    #-    describe 'when saving an event' do
        #-        it 'should use the existing DB connection'
        #-        it 'should create a new DB connection if none exist already'
        #-        it 'should issue the proper SQL'
        #-    end
    #-
        #-    describe 'when loading events with a uid' do
        #-        it 'should only load events for that uid'
        #-        it 'should create an event object for each row returned'
        #-        it 'should return the events in an array ordered by timestamp'
        #-    end
    #-end

