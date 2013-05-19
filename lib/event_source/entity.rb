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
                    :attributes

        def set(attr_name, &block)
            @attributes[attr_name.to_sym] = block.call
        end

        private

        def initialize
            @uid = EventSource::UIDGenerator.generate_id
            @attributes = Hash.new
        end
    end
end

