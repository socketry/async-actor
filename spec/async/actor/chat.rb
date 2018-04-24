
require 'async/queue'

module Chat
	class Room
		def initialize
			@users = {}
		end
		
		def post(user, message)
			count = 0
			
			@users.each do |user, queue|
				queue.enqueue([user, message])
				count += 1
			end
			
			return count
		end
		
		def join(user)
			@users[user] ||= Async::Queue.new
		end
		
		def leave(user)
			@users.delete(user)
			# if @users.delete(user)
			# 	return true
			# end
		end
	end

	class Rooms
		def initialize
			@named = {'ruby' => Room.new}
		end
		
		def list
			return @named.keys
		end
		
		def [] name
			return @named[name]
		end
	end
end
