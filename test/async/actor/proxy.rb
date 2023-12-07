describe Async::Actor::Proxy do
	let(:proxy) {subject.new(Hash.new)}
	
	it "can check for missing methods" do
		expect(proxy).to respond_to(:fetch)
	end
	
	it "can invoke methods" do
		expect(proxy.fetch(:foo, 1)).to be == 1
	end
end
