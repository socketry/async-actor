# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'local'
require_relative 'wrapper'

module Async
	module Actor
		class Server
			def initialize(endpoint)
				@endpoint = endpoint
				
				@wrapper = Wrapper.new(self)
			end
			
			def accept(peer, address, task: Task.current)
				stream = Async::IO::Stream.new(peer)
				
				Async.logger.debug(self) {"Incoming connnection from #{address.inspect} to #{@protocol}"}
				
				packer = @wrapper.packer(stream)
				unpacker = @wrapper.unpacker(stream)
				
				unpacker.each do |message|
					name, *args = *message
					
					
				end
			end
			
			def temporary(actor)
			end
			
			def []= key, actor
			end
			
			def [] key
			end
			
			def invoke(name, args, &block)
				remote_name = "#{@root}:#{name}"
				invoke_queue_name = "#{remote_name}:invoke"
				
				id = @client.call("INCR", "#{remote_name}:calls")
				
				response_queue_name = "#{remote_name}:invoke:#{id}"
				yield_queue_name = block_given? ? "#{remote_name}:yield:#{id}" : nil
				
				push(invoke_queue_name, [args, response_queue_name, yield_queue_name])
				
				while response = pop(response_queue_name)
					what, args = response
					
					case what
					when 'error'
						raise args
					when 'return'
						@client.call("DEL", response_queue_name)
						return args
					when 'yield'
						begin
							result = yield *args
							push(yield_queue_name, ['next', result])
						rescue
							push(yield_queue_name, ['error', $!])
						end
					end
				end
				
				if yield_queue_name
					push(yield_queue_name, ['return', result])
				end
			ensure
			end
		end
	end
end
