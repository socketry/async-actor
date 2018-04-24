
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
	
	it "can enumerate items using yield" do
		subject[:counter] = Counter.new
		
		proxy = subject[:counter]
		
		proxy.increment(3)
		
		items = []
		proxy.each do |item|
			items << item
		end
		
		expect(items).to be == [0, 1, 2]
		
		subject.close
	end
	
	it "can enumerate items using yield and break" do
		subject[:counter] = Counter.new
		
		proxy = subject[:counter]
		
		proxy.increment(3)
		
		items = []
		result = proxy.each do |item|
			items << item
			
			break 'my bones' if item == 1
		end
		
		expect(items).to be == [0, 1]
		expect(result).to be == 'my bones'
		
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
