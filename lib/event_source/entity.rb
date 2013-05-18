module EventSource
    module Entity
        attr_reader :uid

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
        end

        def set_uid(uid)
            @uid = uid
            puts self.inspect, @uid
        end
    end
end

