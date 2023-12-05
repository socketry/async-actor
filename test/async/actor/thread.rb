require 'async/actor/thread'

describe Async::Actor::Thread do
	let(:actor) {subject.start(Array.new)}
	
	it "can add and remove items" do
		actor.push(1)
		actor.push(2)
		actor.push(3)
		
		expect(actor.pop).to be == 3
		expect(actor.pop).to be == 2
		expect(actor.pop).to be == 1
	end
end