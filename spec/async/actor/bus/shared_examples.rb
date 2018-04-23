
require_relative 'counter'

RSpec.shared_examples_for Async::Actor::Bus do
	include_context Async::RSpec::Reactor
	
	it "can setup counter and invoke functions" do
		subject.register('value', Counter.new)
		
		proxy = subject.lookup('value')
		
		proxy.increment
		
		expect(proxy.value).to be == 1
		
		subject.close
	end
end