#!/usr/bin/env ruby

require 'async/reactor'
require_relative '../../lib/async/actor'

# client.rb
user = ARGV[0] || 'test'
room = ARGV[1] || 'ruby'

Async::Reactor.run do
	bus = Async::Actor::Bus::Redis.new('chat')
	rooms = bus[:rooms]
	
	puts "Available rooms:", rooms.list
	
	room = rooms['ruby']
	puts room.inspect
end
