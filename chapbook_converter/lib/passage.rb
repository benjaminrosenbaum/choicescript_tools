class Passage
	attr_reader :chapbook_expression

	DELIMETER = '--'

	def initialize(chapbook_expression, verbose = false)
		@chapbook_expression = chapbook_expression
		@verbose = verbose
	end

	def to_choicescript 
		(header, body) = partitioned

		cs_header = header.map {|decl| Declaration.new(decl).to_choicescript }
		cs_body = body.map{|b| convert_body_line b}

		(cs_header + [""] + cs_body).join("\n")
	end

	def convert_body_line chapbook_body_line
		chapbook_body_line
	end

	def partitioned
		partition_by @chapbook_expression.lines.map(&:chomp), DELIMETER
	end


	private

	#exclude the delimeter element
	def partition_by list, delimeter
		partitioned = [[], []]
		phase = 0
		list.each do |e| 
			if e == delimeter 
				phase = 1 
			else
				partitioned[phase].push(e)
			end
		end
		partitioned
	end

end