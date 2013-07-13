require 'spec_helper'

describe EventSource::Event do
    before :each do
        class Account
            extend EventSource::Entity::ClassMethods
            include EventSource::Entity

            def entity_changes
                {
                    name: 'account1'
                }
            end
        end

        @now = Time.now
        @event_name = 'event1'

        Time.stub!(:now).and_return(@now)

        @acct = Account.create
        @event = EventSource::Event.create('event1', @acct, [1,2,3])
    end

    describe 'when creating an event' do
        it 'should store the entity\'s uid' do
            @event.entity_id.should == @acct.uid
        end

        it 'should serialize and store the entity\'s changes' do
            @event.data.should == [1,2,3].to_json
        end

        it 'should store the name of the event' do
            @event.name.should == @event_name
        end

        it 'should store the time the event was created at' do
            @event.created_at.should == @now
        end

        it 'should store the entity type' do
            @event.entity_type.should == 'account'
        end
    end

    describe 'when saving an event' do
        it 'should save it using the event repository' do
            repo = mock('repo')
            EventSource::EventRepository.stub!(:current).and_return(repo)
            repo.should_receive(:save).with(@event)
            @event.save
        end

        it 'should raise an error if the event was recreated from data' do
            data = {name: 'event', entity_id: 'abc', entity_type: 'account', 
                    created_at: Time.now, data: {}}

            event = EventSource::Event.build_from_data(data)
            expect {event.save}.to raise_error(CannotSaveRebuiltEvent)
        end
    end
end
