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

class Account
    attr_accessor :clients
end

class Client 
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    on_event :change_name do |e, name|
        e.name = name
    end
end

class Account 
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    def on_initialized
        @clients = []
    end

    on_event :add_client do |e, client|
        new_list = e.clients + [client]
        e.clients = new_list
    end
end

client = Client.create
raise if client.uid.nil?

account = Account.create
account.add_client(client)

raise unless account.clients[0].name == client.name

puts 'all good!'
