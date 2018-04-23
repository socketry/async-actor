#!/usr/bin/env ruby

require 'async/reactor'
require_relative '../../lib/async/actor'

class Room
	include Async::Actor
	
	def initialize
		@users = {}
	end
	
	def post(user, message)
		@users.each do |user, queue|
			queue.enqueue([user, message])
		end
	end
	
	def join(user)
		queue = @users[user] = Async::Queue.new
		
		while event = queue.dequeue
			yield event
		end
	ensure
		@users.delete(user)
	end
end

class Rooms
	include Async::Actor
	
	def initialize
		@named = {'ruby' => Room.new}
	end
	
	def list
		return @named.keys
	end
	
	def [] name
		return @named[name]
	end
end

Async::Reactor.run do
	bus = Async::Actor::Bus::Redis.new('chat')
	bus[:rooms] = Rooms.new
end
