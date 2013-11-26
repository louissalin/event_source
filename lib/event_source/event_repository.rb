require 'sequel'

module EventSource
  class EventRepository
    extend EventSource::MemoizeInstance

    attr_reader :db

    def initialize(options)
      if options[:in_memory] 
        @db = Sequel.sqlite
        init_in_memory_schema
      end

      if options[:connect]
        con = options[:connect][:connection_string]
        @db = Sequel.connect(con)
      end
    end

    def save(event)
      count = @db[:events].exclude_where(entity_type: event.entity_type).
        where(entity_id: event.entity_id).count

      raise InvalidEntityID if count > 0
      @db.transaction do
        version = @db[:entity_versions].where(entity_type: event.entity_type)
                                       .select_order_map(:version)
                                       .last
        if version == nil
          version = 0
          @db[:entity_versions].insert(entity_type: event.entity_type, version: version)
        else
          version += 1
          @db[:entity_versions].where(entity_type: event.entity_type).update(version: version)
        end

        @db[:events].insert(name: event.name, entity_type: event.entity_type,
                            entity_id: event.entity_id, data: event.data,
                            created_at: event.created_at, version: version)

        EventSource::Publisher.current.publish(event)
      end
    end

    def get_events(type, uid)
      data = @db[:events].where(entity_type: type.to_s, entity_id: uid).order(:version)
      data.map {|d| create_event(d)}
    end

    private

    def self.default_args
      [in_memory: true]
    end

    def init_in_memory_schema
      @db.create_table :events do
        primary_key :id
        String :name
        String :entity_id
        String :entity_type
        Time :created_at
        String :data
        Integer :version
      end

      @db.create_table :entity_versions do
        String :entity_type
        Integer :version
      end
    end

    def create_event(data)
      EventSource::Event.build_from_data(data)
    end
  end
end

