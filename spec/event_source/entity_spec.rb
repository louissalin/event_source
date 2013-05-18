require 'spec_helper'
require './lib/event_source/entity'

describe EventSource::Entity do
    describe 'UUID'
    describe 'when registering events'
    describe 'when calling event methods'
end


# example
#
# class Account
#   include EventSouce::Entity
#
#   on :deposit do |amount|
#     @balance = amount + @balance
#   end
# end
#
# -- this creates a deposit method on an instance of Account
# -- Calling deposit does:
#       -- execute the block
#       -- add event to Entity's list of events
