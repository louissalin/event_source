require 'spec_helper'

describe EventSource::EventRepository do
    describe 'when initializing the repository' do
        it 'should create a new DB connection if none exist already'
        it 'should use the existing DB connection'
    end

    describe 'when saving an event' do
        describe 'and the uid does not already exist' do
            it 'should issue the proper SQL'
        end

        describe 'and the uid already exists' do
            it 'should save the event if the entity_type is the same'
            it 'should raise an exception if the entity_type is already used with a different uid'
        end
    end

    describe 'when loading events with a uid' do
        it 'should only load events for that uid'
        it 'should create an event object for each row returned'
        it 'should return the events in an array ordered by timestamp'
    end
end
