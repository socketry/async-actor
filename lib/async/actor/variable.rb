# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module Actor
		class Variable
			def self.fulfill(variable)
				variable.set(yield)
				variable = nil
			rescue => error
				variable&.fail(error)
				variable = nil
			ensure
				# throw, etc:
				variable&.fail(RuntimeError.new("Invalid flow control!"))
			end
			
			def initialize
				@set = nil
				@value = nil
				
				@guard = Thread::Mutex.new
				@condition = Thread::ConditionVariable.new
			end
			
			def set(value)
				@guard.synchronize do
					raise "Variable already set!" unless @set.nil?
					
					@set = true
					@value = value
					@condition.broadcast
				end
			end
			
			def fail(error)
				@guard.synchronize do
					raise "Variable already set!" unless @set.nil?
					
					@set = false
					@error = error
					@condition.broadcast
				end
			end
			
			def get
				@guard.synchronize do
					while @set.nil?
						@condition.wait(@guard)
					end
					
					if @set
						return @value
					else
						raise @error
					end
				end
			end
		end
	end
end
