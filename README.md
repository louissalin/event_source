# Event Sourcing

This library is an implementation of the Event Sourcing pattern, where instead of persisting the state of your objects in a data store, it is the sequence of events that led to the objects' state that is stored. In order to rebuild objects, the events must be replayed on each object.

## The event repository

An event store must be initialized. Currently, only the in_memory SQLlite3 type is available.

```ruby
EventSource::EventRepository.create(in_memory: true)
```

## Your entities

An entity is an object that you intend to persist. You must extend and include some class methods and instance methods. Let's create an entity called BankAccount.

```ruby
class BankAccount
  extend EventSource::Entity::ClassMethods
  include EventSource::Entity

end
```

For each of the entity's members that you want to persist, you must create an accessor. Then you must create events for your entity. For example, 'deposit' could be an event on the bank account entity and balance would be something we want to persist.

```ruby
class BankAccount
  extend EventSource::Entity::ClassMethods
  include EventSource::Entity

  attr_accessor :balance

  on_event :deposit do |e, amount|
  end
end
```

Your event handler will receive at least one parameter, which is the instance of the entity being modified. It is used to set the state of your entity by calling the method 'set' on it. All the other parameters will be arguments that must be giving when calling the event. In this case, when calling the deposit event, the caller will have to supply the amount. 

Here's what could go into event handler:

```ruby
  on_event :deposit do |e, amount|
    e.set(:balance) {@balance + amount}
  end
```

The 'set' method does more than simply set the @balance attribute. It also saves the state of your entity into the event so that when the event eventually gets replayed to rebuild this entity, it will know how to set the balance of the account.

To call the event, simply call the 'deposit' method that was created for you:

```ruby
account = BankAccount.create
account.deposit(100)
```

Note that calling the event outside the context of a Entity Repository transaction won't persist the event. (see below)

### unique identifiers

Each entity gets a unique identifier when created the first time. This id is important. You will need it to recreate the entity. You can access it with the 'uid' attribute.

```ruby
account.uid
```

## Creating entities

Call the 'create' class method to create a new instance of your entity.

```ruby
account = BankAccount.create
```

## The Entity Repository

This repository is used to store and load entities. It is also used to monitor changes to entities. When a transaction is created, all changes to all entities and all events created will be saved in the event repository.

### Transactions

```ruby
EventSource::EntityRepository.transaction do
    account.deposit(100)
end
```

The code above will store one event in the event store: a deposit event that adds 100 to the balance of the account.

### Loading an entity

To load an entity, you must create an entity repository and pass it an instance of your event repository, then call 'find'. I know, this isn't the simplest thing yet. It'll improve.

The 'find' method expects an entity type and the entity's unique identifier. The type, by convention, is simply a lowercase undescored string of the entity class name.

```ruby
event_repo = EventSource::EventRepository.current
entity_repo = EventSource::EntityRepository.new(event_repo)
entity = entity_repo.find(:bank_account, uid)
```

