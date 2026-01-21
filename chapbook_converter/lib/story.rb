require 'link'
require 'passage'

class Chunk
	attr_reader :title

	def initialize opening
		@lines = []
		if opening =~ /^:: (.*) \{"position":"(\d+),(\d+)","size":"(\d+),(\d+)"}/
			@label = Link.lablify $1.strip
			# these may be useful later for determining chapters
			@title = $1.strip
			@x = $2.to_i
			@y = $3.to_i 
		elsif opening =~ /^:: (.*)$/
			@label = Link.lablify $1.strip
			@title = $1.strip
		else
			throw "cannot interpret twee chunk #{opening}, #{contents.join("\n")}"
		end
	end

	def add line 
		@lines.push line
	end

	def as_labeled_passage verbose=false
		LabeledPassage.new @label, @lines, verbose
	end
end


class Story

	SPECIAL_PASSAGES = %w{ StoryTitle StoryData }

	attr_reader :passages

	def initialize(text, verbose = false)
		@full_text = text
		@verbose = verbose

		@chunks = []
		chunk = nil
		text.lines.each do |line|
			if line.start_with? '::'
				@chunks.push chunk if chunk
				chunk = Chunk.new line
			else
				chunk.add line if chunk
			end
		end

		@passages = @chunks.reject do |c|
						SPECIAL_PASSAGES.any? {|sp| c.title == sp}
					end.map{|c| c.as_labeled_passage @verbose}
	end

	def to_choicescript
		@passages.map(&:to_choicescript).join("\n")
	end
end