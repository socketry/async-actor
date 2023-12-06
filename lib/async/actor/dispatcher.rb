require 'async'

require_relative 'proxy'
require_relative 'variable'

module Async
	module Actor
		class Dispatcher < Proxy
			class Finalizer
				def initialize(queue, thread)
					@queue = queue
					@thread = thread
				end
				
				def call(id)
					$stderr.puts "Closing queue #{@queue} and thread #{@thread}"
					@queue.close
					@thread.join
				end
			end
				
			def initialize(instance)
				super(instance)
				
				@queue = Queue.new
				@thread = self.__start__(@queue)
				
				# Define a finalizer to ensure the thread is closed:
				ObjectSpace.define_finalizer(self, Finalizer.new(@queue, @thread))
			end
			
			def public_send(*arguments, **options, &block)
				result = Variable.new
				
				@queue.push([arguments, options, block, result])
				
				return result.get
			end
			
			def public_send_ignoring_return(*arguments, **options, &block)
				@queue.push([arguments, options, block])
			end
			
			def __start__(queue)
				::Thread.new do
					Sync do |task|
						while operation = queue.pop
							task.async do
								arguments, options, block, result = operation
								
								Variable.fulfill(result) do
									@instance.public_send(*arguments, **options, &block)
								end
							end
						end
					end
				end
			end
		end
	end
end
