require 'spec_helper'

describe EventSource::Entity do
    describe 'when creating a new entity' do
        it 'should add a unique id to the entity' do 
            class Account
                include EventSource::Entity
                self
            end

            acct = Account.create
            acct.uid.should_not be_nil
        end
    end

    describe 'when registering events'
    describe 'when calling event methods'
end


# example
#
# class Account
#   include EventSouce::Entity
#
#   attributes :balance #, ...
#
#   on :deposit do |amount|
#     new_balance = amount + @balance
#     # do some validation
#
#     set_balance new_balance
#   end
#
#   on :deposit do |amount|
#     # This is version 2
#     # do more stuff
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
