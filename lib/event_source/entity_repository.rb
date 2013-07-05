# the repository should be thread safe. This is accomplished by forcing
# every transaction done (anything from newing up the repo to commiting it) to 
# create their own repo. That way, changes aren't shared.

require 'set'
require 'active_support/inflector'

module EventSource
    class EntityRepository
        extend EventSource::MemoizeInstance

        attr_reader :entities

        class << self
            def transaction
                self.current.clear
                yield
                self.current.commit
            end
        end

        def initialize(event_repo = nil)
            @entities = Set.new
            @event_repo = event_repo
        end

        def clear
            @entities.clear
        end

        def add(entity)
            @entities << entity
        end

        def commit
            # TODO: gather all events of all entities, maintain order and save in batch
            @entities.each {|e| e.save}
            clear
        end

        def find(type, uid)
            entity = @entities.select {|e| e.uid == uid}[0]
            return entity if entity

            events = @event_repo.get_events(type, uid)

            entity_class = type.to_s.camelize.constantize
            if events.count > 0
                entity = entity_class.rebuild(uid, events)
            else
                entity = entity_class.create(uid)
            end

            entity
        end

        private

        def self.default_args
            [EventSource::EventRepository.current]
        end
    end
end
