# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'actor/version'
require_relative 'actor/thread'

module Async
	module Actor
		def self.start
			Thread.new(instance)
		end
	end
end
