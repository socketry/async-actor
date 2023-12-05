module Async
	module Actor
		class Proxy
			def initialize(instance)
				@instance = instance
			end
			
			def method_missing(*arguments, **options, &block)
				@instance.public_send(*arguments, **options, &block)
			end
			
			def respond_to_missing?(name, include_private = false)
				@instance.respond_to?(name, include_private)
			end
		end
	end
end
