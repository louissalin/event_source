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

    def save(events)
      return true if events.count == 0
      return false unless are_for_same_id_and_type(events)

      ensure_are_not_rebuilt(events)

      entity_type = events.first.entity_type
      entity_id = events.first.entity_id

      count = @db[:events].exclude_where(entity_type: entity_type)
      .where(entity_id: entity_id).count

      raise InvalidEntityID if count > 0

      version = @db[:entity_versions].where(entity_id: entity_id)
      .select_order_map(:version)
      .last

      @db.transaction do
        if version == nil
          version = 0
          @db[:entity_versions].insert(entity_id: entity_id, entity_type: entity_type, version: version)
        end

        events.each do |event|

          version += 1
          @db[:events].insert(name: event.name, entity_type: event.entity_type,
                              entity_id: event.entity_id, data: event.data,
                              created_at: event.created_at, version: version)

          EventSource::Publisher.current.publish(event)
        end

        @db[:entity_versions].where(entity_id: entity_id).update(version: version)
      end

      true
    end

    def get_events(type, uid)
      data = @db[:events].where(entity_type: type.to_s, entity_id: uid).order(:version)
      data.map {|d| create_event(d)}
    end

    private

    def are_for_same_id_and_type(events)
      events.map(&:entity_id).uniq.count == 1 && 
        events.map(&:entity_type).uniq.count == 1
    end

    def ensure_are_not_rebuilt(events)
      events.each {|e| raise CannotSaveRebuiltEvent if e.is_rebuilt}
    end

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
        String :entity_id
        String :entity_type
        Integer :version
      end
    end

    def create_event(data)
      EventSource::Event.build_from_data(data)
    end
  end
end

