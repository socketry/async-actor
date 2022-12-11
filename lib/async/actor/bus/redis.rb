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

require 'async/redis/client'

module Async
	module Actor
		module Bus
			class Redis
				def initialize(root = "actors", client = Async::Redis::Client.new)
					@client = client
					@root = root
					
					@actors = {}
					@tasks = []
					
					@wrapper = Wrapper.new(self)
					
					@id = @client.call("INCR", "#{root}:bus:count")
				end
				
				def close
					#keys = @client.call("KEYS", "#{@root}:bus:#{@id}:*")
					#puts "Removing temporaries: #{keys.inspect}"
					# @client.call("DEL", *keys) if keys.any?
					
					@tasks.each(&:stop)
					@actors.clear
					@client.close
				end
				
				def temporary(actor)
					name = "bus:#{@id}:#{actor.object_id}"
					
					unless @actors.key? name
						self[name] = actor
					end
					
					return name
				end
				
				def []= name, actor
					@actors[name] = actor
					
					@tasks << Reactor.run do |task|
						invoke_queue_name = "#{@root}:#{name}:invoke"
						
						while request = pop(invoke_queue_name)
							@tasks << task.async do
								args, response_queue, yield_queue = request
								task.annotate("Handling #{args.first}...")
								
								begin
									if yield_queue
										result = actor.send(*args) do |*args|
											push(response_queue, ['yield', args])
											
											response = pop(yield_queue)
											what, args = response
											
											if what == 'error'
												raise args
											elsif what == 'return'
												return args
											elsif what == 'next'
												next args
											end
										end
									else
										result = actor.send(*args)
									end
									
									push(response_queue, ['return', result]) if response_queue
								rescue
									if response_queue
										push(response_queue, ['error', $!])
									else
										Async.logger.error {"#{$!.class}: #{$!.message} #{$!.backtrace.join("\n")}"}
										Async.logger.error {$!.backtrace.join("\n")}
									end
								end
							end
						end
					end
					
					Proxy.new(self, name)
				end
				
				def [] name
					# if actor = @actors[name]
					# 	return Local::Proxy.new(actor)
					# else
						return Proxy.new(self, name)
					# end
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
				
				protected
				
				def delete(queue)
					Async.logger.debug(self) {"DEL #{queue.ljust(40)}"}
					
					@client.call("DEL", queue)
				end
				
				def push(queue, object)
					Async.logger.debug(self) {"PUSH #{queue.ljust(40)} -> #{object}"}
					
					@client.call("RPUSH", queue, @wrapper.dump(object))
				end
				
				def pop(queue)
					if response = @client.call("BLPOP", queue, 0)
						Async.logger.debug(self) {" POP #{queue.ljust(40)} <- #{@wrapper.load(response[1])}"}
						
						@wrapper.load(response[1])
					end
				end
			end
		end
	end
end
