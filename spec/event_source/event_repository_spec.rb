require 'spec_helper'
require 'active_support/core_ext/numeric/time'

describe EventSource::EventRepository do
  let (:time) {Time.now}

  before do
    @db = double('db', create_table: true)
    Sequel.stub(:sqlite).and_return(@db)

    @event = double('event', name: 'louis', entity_type: 'account', 
                    entity_id: 'abc', data: '{}', created_at: time,
                    is_rebuilt: false)

    @table = double('events')
    @entity_versions_table = double('entity_versions')

    @db.stub(:[]).with(:events).and_return(@table)
    @db.stub(:[]).with(:entity_versions).and_return(@entity_versions_table)
    @db.stub(:transaction).and_yield

    #mock queries on events table
    @result = mock('query_result')
    where = double('where')
    where.stub(:where).with(entity_id: 'abc').and_return(@result)
    @table.stub(:exclude_where).with(entity_type: 'account').and_return(where)

    #mock queries on entity_versions table
    @version_select = double('version_select')
    @version_select.stub(:last).and_return(nil)
    @version_where = double('version_where')
    @version_where.stub(:select_order_map).and_return(@version_select)
    @entity_versions_table.stub(:where).with(entity_id: 'abc').and_return(@version_where)

    @sut = EventSource::EventRepository.create(in_memory: true)
  end

  describe 'when saving events' do
    describe 'and the uid does not already exist' do
      it 'should insert the event' do
        @result.should_receive(:count).and_return(0)
        @entity_versions_table.should_receive(:insert).with(entity_id: 'abc', entity_type: 'account', version: 0)
        @table.should_receive(:insert).with(name: 'louis', entity_type: 'account',
                                            entity_id: 'abc', data: '{}', created_at: time, 
                                            version: 1)
        @version_where.should_receive(:update).with(version: 1)

        @sut.save([@event])
      end

      it 'should raise an error if the event was recreated from data' do
        data = {name: 'event', entity_id: 'abc', entity_type: 'account', 
                created_at: Time.now, data: {}}

        event = EventSource::Event.build_from_data(data)
        expect {@sut.save([event])}.to raise_error(CannotSaveRebuiltEvent)
      end
    end

    describe 'and the uid already exists' do
      it 'should raise an exception if the entity_type is already used with a different uid' do
        @result.should_receive(:count).and_return(1)

        expect {@sut.save([@event])}.to raise_error(InvalidEntityID)
      end
    end

    describe 'and there are already events for this UID' do
      it 'should increase the version number' do
        @version_select.stub(:last).and_return(1)

        @result.should_receive(:count).and_return(0)
        @entity_versions_table.should_not_receive(:insert)
        @table.should_receive(:insert).with(name: 'louis', entity_type: 'account',
                                            entity_id: 'abc', data: '{}', created_at: time, 
                                            version: 2)
        @version_where.should_receive(:update).with(version: 2)

        @sut.save([@event])
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

      dataset.should_receive(:order).with(:version).and_return([])
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
