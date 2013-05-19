require 'spec_helper'

describe EventSource::Event do
    describe 'when creating an event' do
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

            @event_name = 'event1'
            @acct = Account.create
            @event = EventSource::Event.new('event1', @acct)
        end

        it 'should store the entity\'s uid' do
            @event.entity_id.should == @acct.uid
        end

        it 'should serialize and store the entity\'s changes' do
            @event.data.should == @acct.entity_changes.to_json
        end

        it 'should store the name of the event' do
            @event.name.should == @event_name
        end
    end
end
