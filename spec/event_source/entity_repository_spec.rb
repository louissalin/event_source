require 'spec_helper'

describe EventSource::EntityRepository do
    describe 'when adding entities to the repository' do
        it 'should add them to the list' do
            entity = double('entity')
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
    end

    describe 'when committing the repository'
    describe 'when searching for an entity'
end
