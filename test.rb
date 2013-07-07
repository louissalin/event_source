module TestInit
    def create(*args)
        puts 'Created!!'
        original_initialize(*args)
    end

    def self.included(c)
        puts "#{self} included in #{c}"
        puts 'overriding initialize'

        c.class_eval do
            alias :original_initialize :initialize
            alias :initialize :create
        end
    end
end

class Client
    def initialize(a, b)
        puts "a: #{a}"
        puts "b: #{b}"
    end
end

class Client
    include TestInit
end

client = Client.new('hello', 'world')

