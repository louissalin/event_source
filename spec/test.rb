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

entity_repo = EventSource::EntityRepository.new(event_repo)
entity = entity_repo.find(:client, uid)

puts 'loaded entity:'
puts entity.inspect

EventSource::EntityRepository.transaction do
    client.change_name('Some other new name')
end

entity = entity_repo.find(:client, uid)

puts 'loaded entity:'
puts entity.inspect
