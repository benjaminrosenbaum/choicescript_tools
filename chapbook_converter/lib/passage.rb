require 'link'
require 'declaration'

class Passage
	attr_reader :chapbook_lines

	DELIMETER = '--'

	def initialize(chapbook_lines, verbose = false)
		if chapbook_lines.is_a? Array
			@chapbook_lines = chapbook_lines
		elsif chapbook_lines.is_a? String
			@chapbook_lines = chapbook_lines.lines 
		else
			throw "Can't parse #{chapbook_lines} as Twee"
		end
		@verbose = verbose
	end

	def to_choicescript(indent = 0)

		indented = -> (line) { (' ' * indent) + line }

		(header, body) = partitioned

		cs_header = header.map {|decl| Declaration.new(decl).to_choicescript }
		cs_body = body.map{|b| convert_body_line b}

		results = strip_empties(cs_header + [""] + cs_body)

		(main, end_links) = split_off_links_at_end results

		# if the passage ends with links, it's either a pagebreak/goto or a choice block
		link_lines = (end_links.length > 1) ? 
						OptionLocalGoto.as_choicescript_choice_lines(end_links) :  
						end_links.map{|l| PageBreakLocalGoto.map l}

		results = (main + link_lines) 

		results.map{|r| indented.(r)}.join("\n")
	end

	
	def split_off_links_at_end results
		# trim blank lines at end
		inverted = results.reverse

		# pull out final links, ingoring blanks
		coda = inverted.take_while do |r| 
			(Link.is_valid? r) || (is_blank? r)
		end.reject{|r| is_blank? r}.reverse

		#split into before links, links
		[inverted.reverse - coda, coda]
	end

	def convert_body_line chapbook_body_line
		chapbook_body_line.split(/\s/).map do |w|
			# replace simple variables
			rgx = /\{([^ \}]+)\}/
			(rgx.match w) ? w.gsub(rgx, "${#{$1}}" ) : w
		end.join(' ')
	end

	def partitioned
		partition_by @chapbook_lines.map(&:chomp), DELIMETER
	end

	private

	# if the delimiter is not present, it's all body
	# otherwise split in two, excluding the delimeter element
	def partition_by list, delimeter
		if !list.any? {|e| e == delimeter}
			[[], list]
		else
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
		

	def is_blank? line 
		line =~ /^\s*$/
	end

    def strip_empty_preface lines
    	lines.drop_while {|l| is_blank? l}
    end

	def strip_empties lines
		strip_empty_preface((strip_empty_preface lines).reverse).reverse
	end

end


class LabeledPassage
	INDENT = 2

	attr_reader :label

	def initialize(label, chapbook_lines, verbose = false)
		@label = label
		@passage = Passage.new chapbook_lines, verbose
	end

	def to_choicescript
		"\n*label #{label}\n*if collapsible\n" + 
		@passage.to_choicescript(INDENT) + "\n" +
		"*comment end of #{label}"
	end
end