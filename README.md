# Event Sourcing

This library is an implementation of the Event Sourcing pattern, where instead of persisting the state of your objects in a data store, it is the sequence of events that led to the objects' state that is stored. In order to rebuild objects, the events must be replayed on each object.

## The event repository

An event store must be initialized. Currently, only SQL based databases accessible via the Sequel gem can be used.

```ruby
EventSource::EventRepository.create(in_memory: true)
```

Once initialized, the event repository is memoized and can be retrieved with:

```ruby
EventSource::EventRepository.current
```

### Connecting to an existing database
Alternatively, you will probably need to connect to an existing database.

```ruby
EventSource::EventRepository.create(connect: {connection_string: 'sqlite://events.db'})
```

### Schema

In the event you connect to an existing database, the EventRepository will expect the database to contain two tables called "events" and "event_versions" with the following schemas:

table: events
* primary key: id
* string: name
* string: entity_id
* string: entity_type
* time: created_at
* string: data
* integer: version

table: event_versions
* string: entity_type
* string: entity_id
* integer: version

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

Your event handler will receive at least one parameter, which is the instance of the entity being modified. It is used to set the state of your entity by modifying attributes on it. All the other parameters will be arguments that must be giving when calling the event. In this case, when calling the deposit event, the caller will have to supply the amount. 

Here's what could go into event handler:

```ruby
  on_event :deposit do |e, amount|
    e.balance = @balance + amount
  end
```

To call the event, simply call the 'deposit' method that was created for you:

```ruby
account = BankAccount.create
account.deposit(100)
```

Note that calling the event outside the context of a Entity Repository transaction won't persist the event. (see below)

### publishing events

Whenever an event is saved to the event repository, the event will also be published for external applications to respond to. To enable this, you will need to create an instance of EventSource::Publisher and pass it a started Bunny connection and an exchange name (optional. will default to 'event_source.events')

```ruby
conn = Bunny.new("amqp://guest:guest@localhost:5672")
conn.start

EventSource::Publisher.create(connection: conn, exchange_name: 'some_exchange')
```

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

The entity repository needs an instance of an event repository to work. If you decide to create your own instance of the entity repository, be sure to pass one as a parameter to the initialize method. Thankfully, however, since the event repository is memoize, the entity repository will simply call use it if you don't specify your own.

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

The following will use the default event and entity repositories. No need to create your own:

```ruby
entity_repo = EventSource::EntityRepository.current
entity = entity_repo.find(:bank_account, uid)
```

Since the entity repository will automatically grab a memoize event repository, simply creating one ahead of time will ensure that it is picked up by the entity repository:

```ruby
event_repo = EventSource::EventRepository.create(:in_memory => true)
entity_repo = EventSource::EntityRepository.current
entity = entity_repo.find(:bank_account, uid)
```

Alternatively, you can instantiate everything yourself

```ruby
event_repo = EventSource::EventRepository.create(:in_memory => true)
entity_repo = EventSource::EntityRepository.new(event_repo)
entity = entity_repo.find(:bank_account, uid)
```
