require 'async/actor/dispatcher'

describe Async::Actor::Dispatcher do
	it "can invoke finalizer" do
		actor = subject.new(Hash.new)
		# queue = Object.instance_method(:instance_variable_get).bind_call(actor, :@queue)
		actor = nil
		
		3.times{GC.start}
		
		binding.irb
		
		# expect(queue).to be(:closed?)
	end
	
	with "Hash instance" do
		let(:actor) {subject.new(Hash.new)}
		
		it "should be a Hash instance" do
			expect(actor).to be_a(Hash)
			expect(actor).to be(:kind_of?, subject)
		end
		
		it "can add and remove items" do
			actor[:foo] = 1
			actor[:bar] = 2
			
			expect(actor.delete(:foo)).to be == 1
			expect(actor.delete(:bar)).to be == 2
		end
		
		it "correctly handles exceptions" do
			expect do
				actor.fetch(:foo)
			end.to raise_exception(KeyError)
		end
	end
end
