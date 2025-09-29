# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "async"

describe Async::Promise do
	let(:promise) {subject.new}
	
	it "can be fulfilled" do
		begin
			result = :foo
			promise.resolve(result)
		rescue => error
			promise.reject(error)
		end
		
		expect(promise.wait).to be == :foo
	end
	
	it "can be failed" do
		begin
			raise "foo"
		rescue => error
			promise.reject(error)
		end
		
		expect do
			promise.wait
		end.to raise_exception(RuntimeError)
	end
	
	it "can be fulfilled asynchronously" do
		thread = Thread.new do
			promise.wait
		end
		
		Thread.pass until thread.status == "sleep"
		
		promise.resolve(:foo)
		
		expect(thread.value).to be == :foo
	end
end
