module EventSource
    module Entity
        attr_reader :uid,
                    :attributes

        def self.included(base)
            base.extend(ClassMethods)
        end

        module ClassMethods
            def create
                entity = self.new
                entity.set_uid EventSource::UIDGenerator.generate_id

                yield entity if block_given?
                entity
            end

            def on_event(name, &block)
                self.define_method(name) do |*args| 
                    block.call(args)
                end
            end
        end

        def set_uid(uid)
            @uid = uid
        end

        private

        def initialize
            @attributes = Hash.new
        end
    end
end

