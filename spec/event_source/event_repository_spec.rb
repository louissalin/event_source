require 'spec_helper'

describe EventSource::EventRepository do
    describe 'when saving an event' do
        before do
            @db = double('db', create_table: true)
            Sequel.stub(:sqlite).and_return(@db)
            
            @time = Time.now
            @event = double('event', name: 'louis', entity_type: 'account', 
                                     entity_id: 'abc', data: '{}', created_at: @time)

            @table = double('events')
            @db.stub(:[]).and_return(@table)

            @result = mock('query_result')
            @table.stub(:where).with(entity_type: 'account', entity_id: 'abc').and_return(@result)

            @sut = EventSource::EventRepository.create(in_memory: true)
        end

        describe 'and the uid does not already exist' do
            it 'should insert the event' do
                @result.should_receive(:count).and_return(0)
                @table.should_receive(:insert).with(name: 'louis', entity_type: 'account',
                                                    entity_id: 'abc', data: '{}', created_at: @time)

                @sut.save(@event)
            end
        end

        describe 'and the uid already exists' do
            it 'should raise an exception if the entity_type is already used with a different uid' do
                @result.should_receive(:count).and_return(1)

                expect {@sut.save(@event)}.to raise_error(InvalidEntityID)
            end
        end
    end

    describe 'when loading events with a uid' do
        it 'should only load events for that uid'
        it 'should create an event object for each row returned'
        it 'should return the events in an array ordered by timestamp'
    end
end
