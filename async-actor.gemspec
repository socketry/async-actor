# frozen_string_literal: true

require_relative "lib/async/actor/version"

Gem::Specification.new do |spec|
	spec.name = "async-actor"
	spec.version = Async::Actor::VERSION
	
	spec.summary = "A multi-threaded actor implementation where each actor has it's own event loop."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-actor"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-actor/",
		"funding_uri" => "https://github.com/sponsors/ioquatix",
		"source_code_uri" => "https://github.com/socketry/async-actor.git",
	}
	
	spec.files = Dir.glob(["{context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "async", ">= 1"
end
