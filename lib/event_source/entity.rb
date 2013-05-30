module EventSource
    module Entity
        module ClassMethods
            def create(uid = EventSource::UIDGenerator.generate_id)
                entity = self.new
                entity.send(:uid=, uid)

                yield entity if block_given?
                entity
            end

            def rebuild(events)
                entity = self.new

                events.each do |e|
                    data = JSON.parse(e.data)
                    data.keys.each do |attr|
                        entity.send("#{attr}=", data[attr])
                    end
                end

                entity
            end

            def on_event(name, &block)
                self.send(:define_method, name) do |*args|
                    returnValue = block.call(args.unshift(self))
                    entity_events << EventSource::Event.new(name, self)

                    # if repo is nil, that's because this isn't being executed in the context of a
                    # transaction and the result won't be saved
                    repo = EventSource::EntityRepository.current
                    repo.entities << self if repo

                    returnValue
                end
            end
        end

        attr_reader :uid,
                    :entity_changes

        def set(attr_name, &block)
            val = block.call
            @entity_changes[attr_name.to_sym] = val
            self.send("#{attr_name}=", val)
        end

        def entity_events
            @events ||= Array.new
            @events
        end

        def save
            entity_events.each {|e| e.save}
        end

        private

        def initialize
            @entity_changes = Hash.new
        end

        def uid=(new_uid)
            @uid = new_uid
        end
    end
end

