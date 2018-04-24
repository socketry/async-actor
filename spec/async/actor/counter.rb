
class Counter
	def initialize
		@value = 0
	end
	
	attr :value
	
	def increment(amount = 1)
		@value += amount
	end
	
	def each
		return to_enum unless block_given?
		
		@value.times do |i|
			yield i
		end
	end
end
