
require_relative 'lib/async/actor/version'

Gem::Specification.new do |spec|
	spec.name          = "async-actor"
	spec.version       = Async::Actor::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = "A actor based concurrency library."
	spec.homepage      = "https://github.com/socketry/async-redis"

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]
	
	spec.add_dependency("async-redis", "~> 0.1.0")
	spec.add_dependency("msgpack", "~> 1.0")
	
	spec.add_development_dependency "async-rspec", "~> 1.1"
	
	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "rake"
end
