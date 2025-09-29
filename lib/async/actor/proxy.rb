# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "async"

require_relative "variable"

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
				@thread = __start__
				
				# Define a finalizer to ensure the thread is closed:
				::ObjectSpace.define_finalizer(self, Finalizer.new(@queue, @thread))
			end
			
			# @parameter return_value [Symbol] One of :ignore, :promise or :wait.
			def method_missing(*arguments, return_value: :wait, **options, &block)
				unless return_value == :ignore
					result = Variable.new
				end
				
				@queue.push([arguments, options, block, result])
				
				if return_value == :promise
					return result
				else
					return result&.get
				end
			end
			
			protected
			
			def __start__
				::Thread.new do
					::Kernel.Sync do |task|
						while operation = @queue.pop
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
