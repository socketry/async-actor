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
		room.join(user) do |message|
			puts message
		end
	end
	
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	puts "Waiting for input..."
	while line = stdin.read_until("\n")
		puts "Sending text: #{line}"
		room.post(user, line)
	end
end
