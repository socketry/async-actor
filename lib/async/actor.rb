# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative "actor/version"
require_relative "actor/proxy"

# @namespace
module Async
	# @namespace
	module Actor
		# Create a new actor proxy for the given instance.
		# @parameter instance [Object] The target object to wrap in an actor proxy.
		# @returns [Proxy] A new proxy that executes methods asynchronously.
		def self.new(instance)
			Proxy.new(instance)
		end
	end
end
