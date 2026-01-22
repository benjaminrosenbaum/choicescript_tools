require 'clause'

class Declaration
	attr_reader :chapbook_expression

	def initialize(chapbook_expression, story, verbose = false)
		@chapbook_expression = chapbook_expression
		@story = story
		@verbose = verbose
	end
	
	def to_choicescript 
		case chapbook_expression
		when /^([a-zA-Z0-9._]+)\s*\((.+)\)\s*\:\s*(.+)$/
			(vr, c, vl) = [$1, $2, $3]
			puts "conditional case: set #{vr} if #{c} to #{vl}" if @verbose
			var = vr.gsub('.', '_')
			puts "get condition" if @verbose
			cond = Clause.new(c, @verbose).to_choicescript
			puts "get value" if @verbose
			val = Clause.new(vl, @verbose).to_choicescript
			@story.register_var var, val
			"*if (#{cond})\n  *set #{var} #{val}"
		when /^([a-zA-Z0-9._]+)\s*\:\s*(.+)$/
			(vr, vl) = [$1, $2]
			puts "simple case: set #{vr} to #{vl}" if @verbose
			var = vr.gsub('.', '_')
			val = Clause.new(vl, @verbose).to_choicescript
			@story.register_var var, val
			"*set #{var} #{val}"
		when /^\s*$/
			puts "whitespace, ignore" if @verbose
		else
			throw "Cannot parse chapbook declaration line: #{chapbook_expression}"
		end
	end
end