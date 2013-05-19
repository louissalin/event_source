require 'spec_helper'

describe EventSource::Event do
    describe 'when creating an event' do
        it 'should store the entity\'s uid' do
            class Account
                extend EventSource::Entity::ClassMethods
                include EventSource::Entity

                def entity_changes
                    {
                        name: 'account1'
                    }
                end
            end

            acct = Account.create
            event = EventSource::Event.new(acct)

            event.entity_id.should == acct.uid
        end
    end
end
