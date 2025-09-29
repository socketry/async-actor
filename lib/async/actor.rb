# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative "actor/version"
require_relative "actor/proxy"

module Async
	module Actor
		def self.new(instance)
			Proxy.new(instance)
		end
	end
end
