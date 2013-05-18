# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
  
require 'event_source/version'

Gem::Specification.new do |s|
    s.name          = 'command_bus'
    s.version       = EventSource::Version
    s.platform      = Gem::Platform::RUBY
    s.authors       = ['Louis Salin']
    s.email         = ['louis.phil@gmail.com']
    s.homepage      = 'http://github.com/louissalin/event_source'
    s.license       = 'MIT'
    s.summary       = 'Event sourcing framework'
    s.description   = 'Event sourcing allows you to persist changes to your domain instead of the state of your domain'

    s.add_development_dependency 'rspec'

    s.files         = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md)
    s.require_path  = 'lib'
end
