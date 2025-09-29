# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "async/actor"

describe Async::Actor do
	it "can start an actor" do
		actor = Async::Actor.new(Array.new)
		
		expect(actor).to be_a(Array)
	end
	
	it "can restart actor if thread is killed" do
		actor = Async::Actor.new(Array.new)
		
		expect(actor).to be_a(Array)
		
		actor.__send__(:__kill__)
		
		expect(actor).to be_a(Array)
	end
end
