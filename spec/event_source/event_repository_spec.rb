require 'spec_helper'

describe EventSource::EventRepository do
    describe 'when saving an event' do
        it 'should use the existing DB connection'
        it 'should create a new DB connection if none exist already'
        it 'should issue the proper SQL'
    end

    describe 'when loading events with a uid' do
        it 'should only load events for that uid'
        it 'should create an event object for each row returned'
        it 'should return the events in an array ordered by timestamp'
    end
end
