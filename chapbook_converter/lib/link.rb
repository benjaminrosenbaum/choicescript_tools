class Link
	BASIC_LINK = /\[\[(.*)\]\]/
	REDIRECT_LINK = /\[\[(.*)->(.*)\]\]/

	INVALID_LABEL_CHARS = /[^A-Za-z0-9_]+/

	class << self
		def is_valid? text
			text =~ BASIC_LINK
		end

		def lablify text
			'_' + text.downcase.gsub(INVALID_LABEL_CHARS, '_')
    	end
	end

	def initialize(text)
		@text = text
		if text =~ REDIRECT_LINK
			@caption = $1
			@destination = self.class.lablify $2
	    elsif text =~ BASIC_LINK
			@caption = $1
			@destination = self.class.lablify $1
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
			"*page_break #{@caption}\n*goto #{@destination}"
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
			"  ##{@caption}\n    *goto #{@destination}"
	    else
	    	# not a link
	    	throw "Expected valid option link, got #{@text}"
	    end
	end
end