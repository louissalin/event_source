module EventSource
    class EventRepository
        class << self
            def current
                self.new
            end
        end

        def save(event)
        end
    end
end
