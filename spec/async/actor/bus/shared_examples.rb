
require_relative '../counter'
require_relative '../chat'

RSpec.shared_examples_for Async::Actor::Bus do
	include_context Async::RSpec::Reactor
	
	it "can setup counter and invoke functions" do
		subject[:counter] = Counter.new
		
		proxy = subject[:counter]
		
		proxy.increment
		
		expect(proxy.value).to be == 1
		
		subject.close
	end
	
	let(:user) {'alice'}
	let(:room) {'ruby'}
	
	it "can invoke remote functions which return actors" do
		subject[:rooms] = Chat::Rooms.new
		
		Async::Reactor.run do |task|
			rooms = subject[:rooms]
			
			room = rooms['ruby']
			
			task.async do
				queue = room.join(user)
				room.post(user, "Hello World")
				
				message = queue.dequeue
				expect(message).to be == [user, "Hello World"]
				
				room.leave(user)
			end.wait
		end.wait
		
		subject.close
	end
end
