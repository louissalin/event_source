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
uid = client.uid

EventSource::EntityRepository.transaction do
    client.change_name('new name')
end

event_repo = EventSource::EventRepository.current
puts 'Events in the database:'
event_repo.db['select * from events'].each do |row|
    puts row
end

entity_repo = EventSource::EntityRepository.current
entity = entity_repo.find(:client, uid)

raise unless entity.uid == client.uid
raise unless entity.name == client.name
raise unless entity.name == 'new name'

EventSource::EntityRepository.transaction do
    entity.change_name('Some other new name')
end

entity = entity_repo.find(:client, uid)

raise unless entity.name == 'Some other new name'
puts 'all good!'
