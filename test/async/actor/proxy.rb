# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/actor/proxy'

describe Async::Actor::Proxy do
	with "Hash instance" do
		let(:actor) {subject.new(Hash.new)}
		
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
		
		it "can ignore the result" do
			actor[:foo] = 1
			
			expect(actor.delete(:foo, ignore_return: true)).to be == nil
		end
	end
	
	describe Async::Actor::Proxy::Finalizer do
		let(:queue) {::Thread::Queue.new}
		let(:thread) {::Thread.new{queue.pop}}
		
		let(:finalizer) {subject.new(queue, thread)}
		
		it "closes the queue" do
			finalizer.call(1)
			
			expect(queue).to be(:closed?)
			thread.join
		end
	end
end
