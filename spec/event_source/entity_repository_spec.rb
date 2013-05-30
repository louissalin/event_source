require 'spec_helper'

describe EventSource::EntityRepository do

    let(:entity) {double('entity')}

    describe 'when adding entities to the repository' do
        it 'should add them to the list' do
            sut = EventSource::EntityRepository.new
            sut.add(entity)

            sut.entities.should include(entity)
        end
    end

    describe 'when starting a transaction' do
        it 'should create a new repo and make it available' do
            EventSource::EntityRepository.transaction do 
                repo = EventSource::EntityRepository.current
                repo.should_not be_nil
                repo.should == EventSource::EntityRepository.current
            end
        end

        it 'should not make the repo available outside the transaction block' do
            EventSource::EntityRepository.transaction do 
            end

            EventSource::EntityRepository.current.should be_nil
        end

        it 'should commit the repository after the transaction is successful' do
            entity.should_receive(:save)

            EventSource::EntityRepository.transaction do 
                EventSource::EntityRepository.current.add(entity)
            end
        end
    end

    describe 'when committing the repository' do
        it 'should save each entity in the list' do
            sut = EventSource::EntityRepository.new
            sut.add(entity)

            entity.should_receive(:save)
            sut.commit
        end
    end

    describe 'when searching for an entity' do
        let(:uid) {'123'}

        it 'should return a pre loaded entity if possible' do
            entity.stub!(:uid).and_return(uid)

            sut = EventSource::EntityRepository.new
            sut.add(entity)
            
            loaded_entity = sut.find(:entity, uid)
            loaded_entity.object_id.should == entity.object_id
        end

        it 'should rebuild an entity with its events if there is no pre loaded entities' do
            name = 'new name'

            class Client
            end

            event = double('event', name: 'name', entity_id: uid,
                                    data: '{}', create_at: Time.now)

            events = [event]
            event_repo = double('event_repo', get_events: events)

            sut = EventSource::EntityRepository.new(event_repo)

            Client.should_receive(:rebuild).with(events)
            loaded_entity = sut.find(:client, uid)
        end

        it 'should create a new entity when there are no events to replay' do
            class Client
            end

            event_repo = double('event_repo', get_events: [])
            sut = EventSource::EntityRepository.new(event_repo)

            Client.should_receive(:create).with(uid)
            sut.find(:client, uid)
        end
    end
end
