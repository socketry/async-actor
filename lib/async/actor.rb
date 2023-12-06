require_relative 'actor/version'
require_relative 'actor/thread'

module Async
	module Actor
		def self.start
			Thread.new(instance)
		end
	end
end
