require './lib/event_source'

EventSource::EventRepository.create(in_memory: true)

class Wheel
    include EventSource::ValueObject

    attr_reader :diameter

    def initialize(diameter)
        @diameter = diameter
    end
end

class CrazyCar
    extend EventSource::Entity::ClassMethods
    include EventSource::Entity

    attr_accessor :front_wheels, :rear_wheels

    on_event :add_wheels do |e, diameter|
        w1 = Wheel.new(diameter)
        e.set(:front_wheels) {[w1, w1]}

        w2 = Wheel.new(diameter + 10)
        e.set(:rear_wheels) {[w2, w2]}
    end
end

entity_repo = EventSource::EntityRepository.current

car = CrazyCar.create
EventSource::EntityRepository.transaction do
    car.add_wheels(30)
end

loaded_car = entity_repo.find(:crazy_car, car.uid)
raise unless loaded_car.front_wheels.count == 2
puts loaded_car.front_wheels[0].inspect
puts loaded_car.rear_wheels.inspect
raise unless loaded_car.front_wheels[0].diameter == 30
raise unless loaded_car.rear_wheels[0].diameter == 40

puts 'all good!'
