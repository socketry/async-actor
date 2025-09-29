# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "async"

module Async
	module Actor
		# Represents an asynchronous proxy that wraps an object and executes its methods in a separate thread.
		class Proxy < BasicObject
			# Handles cleanup of proxy resources when the proxy is garbage collected.
			class Finalizer
				# Initialize a new finalizer.
				# @parameter queue [Thread::Queue] The message queue to close.
				# @parameter thread [Thread] The worker thread to join.
				def initialize(queue, thread)
					@queue = queue
					@thread = thread
				end
				
				# Clean up proxy resources by closing the queue and joining the thread.
				# @parameter id [Object] The object id (unused but required by ObjectSpace.define_finalizer).
				def call(id)
					@queue.close
					@thread.join
				end
			end
			
			# Initialize a new proxy for the target object.
			# @parameter target [Object] The object to wrap with asynchronous method execution.
			def initialize(target)
				@target = target
				
				@queue = ::Thread::Queue.new
				@thread = __start__
				
				# Define a finalizer to ensure the thread is closed:
				::ObjectSpace.define_finalizer(self, Finalizer.new(@queue, @thread))
			end
			
			# @parameter return_value [Symbol] One of :ignore, :promise or :wait.
			def method_missing(*arguments, return_value: :wait, **options, &block)
				unless return_value == :ignore
					result = Promise.new
				end
				
				@queue.push([arguments, options, block, result])
				
				if return_value == :promise
					return result
				else
					return result&.wait
				end
			end
			
			protected
			
			def __start__
				::Thread.new do
					::Kernel.Sync do |task|
						while operation = @queue.pop
							task.async do
								arguments, options, block, result = operation
								
								# Fulfill the promise with the result of the method call:
								Promise.fulfill(result) do
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
