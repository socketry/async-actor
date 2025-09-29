# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "async/actor/variable"

describe Async::Actor::Variable do
	let(:variable) {subject.new}
	
	it "can be fulfilled" do
		Async::Actor::Variable.fulfill(variable) do
			:foo
		end
		
		expect(variable.get).to be == :foo
	end
	
	it "can be failed" do
		Async::Actor::Variable.fulfill(variable) do
			raise "foo"
		end
		
		expect do
			variable.get
		end.to raise_exception(RuntimeError)
	end
	
	it "can be fulfilled asynchronously" do
		thread = Thread.new do
			variable.get
		end
		
		Thread.pass until thread.status == "sleep"
		
		variable.set(:foo)
		
		expect(thread.value).to be == :foo
	end
end
