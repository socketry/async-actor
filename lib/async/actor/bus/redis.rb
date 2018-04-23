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
				end
				
				def close
					@tasks.each(&:stop)
					@actors.clear
					@client.close
				end
				
				def temporary(actor)
					name = actor.object_id.to_s
					
					unless @actors.key? name
						self[name] = actor
					end
					
					return name
				end
				
				def []= name, actor
					@actors[name] = actor
					
					@tasks << Reactor.run do
						invoke_queue_name = "#{@root}:#{name}:invoke"
						
						while request = @client.call("BLPOP", invoke_queue_name, 0)
							# puts "Request: #{request}"
							what, args, response_queue = @wrapper.load(request[1])
							
							case what
							when 'send'
								begin
									result = actor.send(*args)
									@client.call("RPUSH", response_queue, @wrapper.dump(["return", result]))
								rescue
									@client.call("RPUSH", response_queue, @wrapper.dump(["error", $!]))
								end
							when 'resume'
								begin
									result = actor.send(*args) do |*args|
										@client.call("RPUSH", response_queue, @wrapper.dump(["yield", args]))
									end
									
									@client.call("RPUSH", response_queue, @wrapper.dump(["return", result]))
								rescue
									@client.call("RPUSH", response_queue, @wrapper.dump(["error", $!]))
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
					
					response_queue_name = "#{remote_name}:invoke\##{id}"
					
					@client.call("RPUSH", invoke_queue_name, @wrapper.dump([block_given? ? "resume" : "send", args, response_queue_name]))
					
					while response = @client.call("BLPOP", response_queue_name, 0)
						# puts "Response: #{response}"
						what, args = @wrapper.load(response[1])
						
						case what
						when 'error'
							raise args
						when 'return'
							@client.call("DEL", response_queue_name)
							return args
						when 'yield'
							yield *args
						end
					end
				end
			end
		end
	end
end
