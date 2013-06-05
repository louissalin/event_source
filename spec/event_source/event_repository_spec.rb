require 'spec_helper'
require 'active_support/core_ext/numeric/time'

describe EventSource::EventRepository do
    let (:time) {Time.now}

    before do
        @db = double('db', create_table: true)
        Sequel.stub(:sqlite).and_return(@db)

        @event = double('event', name: 'louis', entity_type: 'account', 
                        entity_id: 'abc', data: '{}', created_at: time)

        @table = double('events')
        @db.stub(:[]).and_return(@table)

        @result = mock('query_result')
        @table.stub(:where).with(entity_type: 'account', entity_id: 'abc').and_return(@result)

        @sut = EventSource::EventRepository.create(in_memory: true)
    end

    describe 'when saving an event' do
        describe 'and the uid does not already exist' do
            it 'should insert the event' do
                @result.should_receive(:count).and_return(0)
                @table.should_receive(:insert).with(name: 'louis', entity_type: 'account',
                                                    entity_id: 'abc', data: '{}', created_at: time)

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
        it 'should only load events for that uid' do
            dataset = double('dataset', order: [])
            @table.should_receive(:where).with(entity_type: 'account', entity_id: 'abc').
                   and_return(dataset)

            @sut.get_events('account', 'abc')
        end

        it 'should order events by created_at in ascending order' do
            dataset = double('dataset')
            @table.stub(:where).with(entity_type: 'account', entity_id: 'abc').
                   and_return(dataset)

            dataset.should_receive(:order).with(:created_at).and_return([])
            @sut.get_events('account', 'abc')
        end

        it 'should create an event object for each row returned' do
            data = [{id: 1, name: 'event1', entity_id: 'abc', entity_type: 'account',
                     created_at: time - 1.hours, data: {}},
                    {id: 1, name: 'event2', entity_id: 'abc', entity_type: 'account',
                     created_at: time, data: {}}
            ]

            dataset = double('dataset', order: data)
            
            @table.stub(:where).with(entity_type: 'account', entity_id: 'abc').
                   and_return(dataset)

            events = @sut.get_events('account', 'abc')

            events[0].name.should == 'event1'
            events[0].entity_id.should == 'abc'
            events[0].entity_type.should == 'account'
            events[0].data.should == {}

            events[1].name.should == 'event2'
            events[1].entity_id.should == 'abc'
            events[1].entity_type.should == 'account'
            events[1].data.should == {}
        end
    end
end
