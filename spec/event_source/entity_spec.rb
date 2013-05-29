require 'spec_helper'

describe EventSource::Entity do
    before :each do
        class Account
            extend EventSource::Entity::ClassMethods
            include EventSource::Entity

            on_event :do_something do |e, arg1, arg2|
                "#{arg1}#{arg2}"
            end
        end

        class Client
            extend EventSource::Entity::ClassMethods
            include EventSource::Entity

            attr_accessor :first_name

            on_event :noop do 
            end

            on_event :change_first_name do |e, name|
                e.set(:first_name) {name}
            end
        end

        @client = Client.create
        @acct = Account.create
    end

    describe 'when creating a new entity' do
        it 'should add a unique id to the entity' do 
            @acct.uid.should_not be_nil
        end
    end

    describe 'when registering events' do
        it 'should create a method with the same name as the event' do
            @acct.methods.should include(:do_something)
        end

        it 'should create the method with all require arguments' do
            @acct.do_something(1, 2).should == '12'
        end

        it 'should create an event and add it to the list of entity events' do
            @acct.do_something(1, 2)

            event = @acct.entity_events[0]
            event.name.should == 'do_something'
            event.entity_id.should == @acct.uid
            event.data.should == @acct.entity_changes.to_json
        end
    end

    describe 'when calling event methods' do

        it 'should start a recording of state changes' do
            @client.noop
            @client.entity_changes.keys.should be_empty
        end

        it 'should add xxx to entity changes when calling set(:xxx)' do
            name = 'Louis'
            @client.change_first_name name
            @client.entity_changes[:first_name].should == name
        end

        it 'should set xxx when set(:xxx) is called' do
            name = 'Louis'
            @client.change_first_name name
            @client.first_name.should == name
        end

        it 'should add the entity to the entity repository' do
            repo = double('event_repo')
            repo.stub!(:save)

            EventSource::EventRepository.stub!(:current).and_return(repo)

            EventSource::EntityRepository.transaction do
                @client.change_first_name 'whatever'
                EventSource::EntityRepository.current.entities.should include(@client)
            end
        end
    end

    describe 'when saving an entity' do
        it 'should save the changed events on the entity' do
            @client.change_first_name 'whatever'
            @client.entity_events[0].should_receive(:save)
            @client.save
        end
    end

    describe 'when rebuilding an entity' do
        it 'should replay events and update the state'
    end
end


# example
#
# class Account
#   include EventSouce::Entity
#
#   attributes :balance #, ...
#
#   on_event :deposit do |entity, amount|
#     # do some validation
#
#     entity.set (:balance) {amount + @balance}
#   end
# end
#
# Account.create
#
# -- this creates a deposit method on an instance of Account
# -- Calling deposit does:
#       -- set up a recording of attribute changes (state changes of entity)
#       -- execute the block
#       -- change state via set_attribute
#           -- this adds to the recording of attribute changes
#       -- exit the block
#           -- this builds an event object with list attributes and values
#       -- add event to Entity's list of events
#
# -- building an entity from events will only build the attribute list
