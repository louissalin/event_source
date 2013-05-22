# the repository should be thread safe. This is accomplished by forcing
# every transaction done (anything from newing up the repo to commiting it) to 
# create their own repo. That way, changes aren't shared.

module EventSource
    class EntityRepository
        attr_reader :entities

        class << self
            @@current = nil

            def transaction
                @@current = self.new
                yield
                @@current = nil
            end

            def current
                @@current
            end
        end

        def initialize
            @entities = Set.new
        end

        def add(entity)
            @entities << entity
        end
    end
end
