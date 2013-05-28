require './lib/event_source'

EventSource::EventRepository.create(in_memory: true)

class Client 
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    attr_accessor :name

    on_event :change_name do |e, name|
        e.set(:name) {name}
    end
end

client = Client.create

EventSource::EntityRepository.transaction do
    client.change_name('new name')
end
