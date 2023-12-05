require 'async'

require_relative 'proxy'

module Async
	module Actor
		class Thread < Proxy
			def self.start(instance)
				self.new(instance).tap(&:__start__)
			end
			
			def initialize(instance)
				super(instance)
				
				@queue = Queue.new
				@thread = nil
			end
			
			def public_send(*arguments, **options, &block)
				result = ::Thread::Queue.new
				
				@queue.push(proc do
					result = @instance.public_send(*arguments, **options, &block)
					result.push(result)
				end)
				
				return result.pop
			end
			
			def public_send_ignoring_return(*arguments, **options, &block)
				@queue.push(proc do
					@instance.public_send(*arguments, **options, &block)
				end)
			end
			
			def __start__
				@thread ||= ::Thread.new do
					Sync do
						while operation = @queue.pop
							operation.call
						end
					end
				end
			end
			
			def __close__
				@queue.close
				@thread&.join
			end
		end
	end
end
