
require 'irb'

require 'async'
require 'async/io/host_endpoint'

require_relative '../../lib/async/actor'

wrapper = Async::Actor::Bus::Wrapper.new(Async::Actor::Bus::Local.new)

binding.irb

Async do
	endpoint = Async::IO::Endpoint.tcp("localhost", 9292)
	server = Async::Actor::Bus::Server.new(endpoint)
	
	server[:x] = 10
	
	task = server.run

	client = Async::Actor::Bus::Remote.new(endpoint)
	
	puts client[:x]
end
	