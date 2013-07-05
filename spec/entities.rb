require './lib/event_source'

EventSource::EventRepository.create(in_memory: true)


class Client
    def name=(value)
        @name = value
    end

    def name
        @name
    end
end

class Client 
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    on_event :change_name do |e, name|
        e.set(:name) {name}
    end
end

client = Client.create
raise if client.uid.nil?
