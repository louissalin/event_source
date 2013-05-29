# the repository should be thread safe. This is accomplished by forcing
# every transaction done (anything from newing up the repo to commiting it) to 
# create their own repo. That way, changes aren't shared.

require 'set'
require 'active_support/inflector'

module EventSource
    class EntityRepository
        attr_reader :entities

        class << self
            @@current = nil

            def transaction
                @@current = self.new
                yield
                @@current.commit
                @@current = nil
            end

            def current
                @@current
            end
        end

        def initialize(event_repo = nil)
            @entities = Set.new
            @event_repo = event_repo
        end

        def add(entity)
            @entities << entity
        end

        def commit
            # TODO: gather all events of all entities, maintain order and save in batch
            @entities.each {|e| e.save}
        end

        def find(type, uid)
            entity = @entities.select {|e| e.uid == uid}[0]
            return entity if entity

            events = @event_repo.get_events(uid)
            entity = type.to_s.camelize.constantize.rebuild(events)
        end
    end
end
