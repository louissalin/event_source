module EventSource
  module Entity
    module ClassMethods
      def create(uid = EventSource::UIDGenerator.generate_id)
        entity = self.new
        entity.send(:uid=, uid)

        yield entity if block_given?
        entity
      end

      def rebuild(uid, events)
        @rebuilding = true
        return self.create(uid) if events.length == 0

        entity = self.new
        entity.send(:uid=, uid)

        events.each do |e|
          entity.send(e.name, *(e.get_args))
        end
        @rebuilding = false

        entity
      end

      def on_event(name, &block)
        self.send(:define_method, name) do |*args|
          block_args = [self] + args
          returnValue = block.call(block_args)
          return if @rebuilding

          entity_events << EventSource::Event.create(name, self, args)

          # if repo is nil, that's because this isn't being executed in the context of a
          # transaction and the result won't be saved
          repo = EventSource::EntityRepository.current
          repo.add(self) if repo

          returnValue
        end
      end
    end

    attr_reader :uid

    def get_type
      self.class.to_s.underscore
    end

    def entity_events
      @events ||= Array.new
      @events
    end

    def save
      EventSource::EventRepository.current.save(entity_events)
    end

    private

    def initialize
      if defined? on_initialized
        on_initialized
      end
    end

    def uid=(new_uid)
      @uid = new_uid
    end
  end
end

