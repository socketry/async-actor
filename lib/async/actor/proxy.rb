# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async'

require_relative 'variable'

module Async
	module Actor
		class Proxy < BasicObject
			class Finalizer
				def initialize(queue, thread)
					@queue = queue
					@thread = thread
				end
				
				def call(id)
					@queue.close
					@thread.join
				end
			end
				
			def initialize(target)
				@target = target
				
				@queue = ::Thread::Queue.new
				@thread = self.__start__(@queue)
				
				# Define a finalizer to ensure the thread is closed:
				::ObjectSpace.define_finalizer(self, Finalizer.new(@queue, @thread))
			end
			
			def method_missing(*arguments, ignore_return: false, **options, &block)
				unless ignore_return
					result = Variable.new
				end
				
				@queue.push([arguments, options, block, result])
				
				return result&.get
			end
			
			def __start__(queue)
				::Thread.new do
					::Kernel.Sync do |task|
						while operation = queue.pop
							task.async do
								arguments, options, block, result = operation
								
								Variable.fulfill(result) do
									@target.public_send(*arguments, **options, &block)
								end
							end
						end
					end
				end
			end
		end
	end
end
