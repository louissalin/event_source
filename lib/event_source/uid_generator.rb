require 'uuidtools'

module EventSource
    class UIDGenerator
        def self.generate_id
            UUIDTools::UUID.timestamp_create.to_s
        end
    end
end
