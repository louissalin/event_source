module EventSource
    module Entity
        module ClassMethods
            def create
                entity = self.new

                yield entity if block_given?
                entity
            end

            def on_event(name, &block)
                self.define_method(name) do |*args| 
                    block.call(args.unshift(self))
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

        private

        def initialize
            @uid = EventSource::UIDGenerator.generate_id
            @entity_changes = Hash.new
        end
    end
end

