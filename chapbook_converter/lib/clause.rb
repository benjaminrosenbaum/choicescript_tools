
class Clause
	attr_reader :chapbook_expression

	def initialize(chapbook_expression, verbose = false)
		@chapbook_expression = "#{chapbook_expression} " #add a trailing space to make life easier
		@verbose = verbose
	end

	TRANSFORMS = { 
				   '===' => '=',
				   '!==' => '!=',
				   '==' => '=',
			       '.' => '_',
			       '&&' => 'and',
			       '||' => 'or' }

	def to_choicescript 
		tokenized.map do |token|
			if token =~ /^'(.*)'([^']*)$/
				puts "found '#{$1}'#{$2}, converting to \"#{$1}\"#{$2}" if @verbose
				"\"#{$1}\"#{$2}"
			elsif token =~ /".*"/
				puts "leaving alone quoted token #{token}"  if @verbose
				token
			else
				TRANSFORMS.inject(token) do |tk, (from, to)|
					tk.gsub(from, to)
				end.tap do |result|
					puts "transformed #{token} to #{result}"  if @verbose
				end 
			end 
		end.join(' ')
	end

	def tokenized 
		tokenize chapbook_expression
	end

	private

	def tokenize expr 
		doublequoting = false
		singlequoting = false
		previous_char = nil
		current_word = ""
		result = expr.split('').inject([]) do |tokens, c|
			puts "tokenizing #{expr}, tokens: #{tokens}, current_word: #{current_word}, c:#{c}, sq:#{singlequoting}, dq:#{doublequoting}" if @verbose
			case 
			when c =~ /\s/ && !singlequoting && !doublequoting
				tokens.push(current_word) if current_word.length > 0
				current_word = ""
			when c =~ /'/ && (singlequoting || previous_char !~ /[A-Za-z]/)
				singlequoting = !singlequoting
				current_word += c 
			when c =~ /"/
				doublequoting = !doublequoting
				current_word += c 
			else
				current_word += c
			end
			previous_char = c
			tokens
		end
		puts "result is #{result}, current_word is #{current_word}"  if @verbose
		result.push(current_word.strip) if current_word.strip.length > 0
		result
	end

	def is_delimited_with expr, c 
		(expr.start_with? c) && (expr.end_with? c)
	end
end