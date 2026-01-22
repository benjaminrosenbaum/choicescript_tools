class Link
	LIST_PREFACE = /^> /
	RAW_CS_PREFACE = /^\s*CS\|/
	BASIC_LINK = /\[\[(.*)\]\]/
	REDIRECT_LINK = /\[\[(.*)->(.*)\]\]/

	NAV_LINK = /\{nav choice:\s*(.*),\s*set:\s*(.*),\s*to:\s*(.*),\s*label:\s*(.*)\s*\}/

	INVALID_LABEL_CHARS = /[^A-Za-z0-9_]+/

	class << self
		def is_valid? text
			text =~ BASIC_LINK || text =~ NAV_LINK
		end

		def variablize text 
			text.downcase.gsub(INVALID_LABEL_CHARS, '_')
		end

		def lablify text
			variablize('_' + text.sub(RAW_CS_PREFACE, ''))
    	end

    	def and_line text, indent = 0
    		"\n#{' ' * indent}#{text}" if text
    	end

    	def unquote text 
			case text 
			when /"(.*)"/
				$1
	        when /'(.*)'/
	        	$1
	        else
	        	text
	        end
	    end
	end

	def initialize(text, verbose = false)
		@verbose = verbose

		puts "Analyzing link #{text}" if @verbose
		@text = text.sub(LIST_PREFACE, '')
		if text =~ NAV_LINK
			@caption = Link.unquote $4
			@destination = self.class.lablify(Link.unquote $1)
			@side_effect = "*set #{Link.variablize(Link.unquote $2)} #{$3.gsub("'", '"')}"
			puts "Got nav link labeled #{@caption} with destination #{@destination} and side effect #{@side_effect}" if @verbose
		elsif text =~ REDIRECT_LINK
			@caption = $1
			@destination = self.class.lablify $2 
			puts "Got redirect link to #{@destination} labeled #{@caption}"
	    elsif text =~ BASIC_LINK
			@caption = $1
			@destination = self.class.lablify $1
			puts "Got link to #{@destination} labeled #{@caption}"
		end
	end
	
end

class PageBreakLocalGoto < Link
	class << self
		def map text 
			PageBreakLocalGoto.new(text).to_choicescript
		end
	end

	def to_choicescript 
		if @caption
			"*page_break #{@caption}#{self.class.and_line @side_effect}\n*goto #{@destination}"
	    else
	    	# not a link
	    	@text
	    end
	end
end

class OptionLocalGoto < Link
	class << self
		def as_choicescript_choice_lines links
			["*choice"] + links.flat_map do |link| 
				OptionLocalGoto.new(link).to_choicescript.split("\n")
			end
		end
	end

	def to_choicescript 
		if @caption
			"  ##{@caption}#{self.class.and_line @side_effect, 4}\n    *goto #{@destination}"
	    else
	    	# not a link
	    	throw "Expected valid option link, got #{@text}"
	    end
	end
end