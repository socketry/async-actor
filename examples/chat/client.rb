#!/usr/bin/env ruby

require 'async/reactor'
require_relative '../../lib/async/actor'

# client.rb
user = ARGV[0] || 'test'
room = ARGV[1] || 'ruby'

Async::Reactor.run do |task|
	bus = Async::Actor::Bus::Redis.new('chat')
	rooms = bus[:rooms]
	
	puts "Available rooms:", rooms.list
	
	room = rooms['ruby']
	
	task.async do
		room.join(user) do |from_user, message|
			puts "#{from_user}: #{message}"
		end
	end
	
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	while line = stdin.read_until("\n")
		room.post(user, line)
	end
end
