require './spec/test_helper'
require 'bunny'

puts "this test requires that a rabbitmq server run at localhost:5672\n"

conn = Bunny.new("amqp://guest:guest@localhost:5672")
conn.start

ex_name = 'test.events'

EventSource::EventRepository.create(in_memory: true)
EventSource::Publisher.create(connection: conn, exchange_name: ex_name)

class Client 
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    attr_accessor :name

    on_event :change_name do |e, name|
        e.name = name
    end
end

ch = conn.create_channel
x = ch.fanout(ex_name)
q = ch.queue('test', auto_delete: true).bind(x)

received = false
q.subscribe do |delivery_info, properties, payload|
    puts 'message received'
    received = true
end

client = Client.create
uid = client.uid

EventSource::EntityRepository.transaction do
    client.change_name('new name')
end

sleep 2
conn.close
raise unless received

puts 'all good!'

