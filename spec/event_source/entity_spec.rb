require 'spec_helper'

describe EventSource::Entity do
    before :each do
        class Account
            extend EventSource::Entity::ClassMethods
            include EventSource::Entity

            on_event :deposit do |e, arg1, arg2|
                "#{arg1}#{arg2}"
            end
        end

        @acct = Account.create
    end

    describe 'when creating a new entity' do
        it 'should add a unique id to the entity' do 
            @acct.uid.should_not be_nil
        end
    end

    describe 'when registering events' do
        it 'should create a method with the same name as the event' do
            @acct.methods.should include(:deposit)
        end

        it 'should create the method with all require arguments' do
            @acct.deposit(1, 2).should == '12'
        end
    end

    describe 'when calling event methods' do
        before :each do
            class Client
                extend EventSource::Entity::ClassMethods
                include EventSource::Entity

                on_event :noop do 
                end

                on_event :change_first_name do |e, name|
                    e.set(:first_name) {name}
                end
            end

            @client = Client.create
        end

        it 'should start a recording of state changes' do
            @client.noop
            @client.attributes.keys.should be_empty
        end

        it 'should update attribute xxx when calling set(:xxx)' do
            name = 'Louis'
            @client.change_first_name name
            @client.attributes[:first_name].should == name
        end
    end

    describe 'when reading attributes' do
        it 'should return the right value' do
            name = 'account1'
            @acct.set(:name) {name}
            @acct.get(:name).should == name
        end
    end
end


# example
#
# class Account
#   include EventSouce::Entity
#
#   attributes :balance #, ...
#
#   on_event :deposit do |e, amount|
#     # do some validation
#
#     e.set (:balance) {amount + @balance}
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
