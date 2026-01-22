require 'link'
require 'passage'

class Chunk
	attr_reader :title, :lines

	IGNORED_CHUNKS = %w{StoryData StoryScript StoryStylesheet}

	def initialize opening, story, verbose=false
		@story = story
		@lines = []
		@verbose = verbose
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

	def is_story_title
		@title == 'StoryTitle'
	end

	def is_ignored
		is_story_title || IGNORED_CHUNKS.any? {|w| @title.start_with? w}
	end

	def add line 
		@lines.push line
	end

	def as_labeled_passage 
		LabeledPassage.new @label, @lines, @story, @verbose, false
	end

	def as_labeled_passage_raw_choicescript 
		LabeledPassage.new @label, @lines, @story, @verbose, true
	end
end


class Story

	attr_reader :passages, :title, :variables

	def initialize(text, verbose = false)
		@full_text = text
		@verbose = verbose

		@variables = {'collapsible' => "true"}

		@chunks = []
		chunk = nil
		text.lines.each do |line|
			if line.start_with? '::'
				puts "new chunk starting, #{chunk ? "finish #{chunk.title}" : 'first one'}" if @verbose
				if chunk
					if chunk.is_story_title
						puts "StoryTitle chunk contains: #{chunk.lines.first}" if @verbose
						@title = chunk.lines.first.chomp
					end

					unless chunk.is_ignored
						@chunks.push chunk
					end
				end
				chunk = Chunk.new line, self, @verbose
			else
				chunk.add line if chunk
			end
		end
		
		#last one
		@chunks.push chunk if (chunk && !chunk.is_ignored)

		@passages = @chunks.map do |c| 
			puts "examining #{c.title}" if @verbose
			unless c.title.start_with? "CS|" 
				override = @chunks.find{|ovr| ovr.title == "CS|#{c.title}" }
				if override
					puts "found override #{override.title}" if @verbose
					override.as_labeled_passage_raw_choicescript 
			    else
			    	puts "create passage for #{c.title}" if @verbose
					c.as_labeled_passage
				end
			end
		end.compact

		puts "got story titled #{@title} with #{@passages.length} passages" if @verbose
	end

	def chapters
		['chapter_1']
	end

	def register_var var, val 
		unless @variables.keys.include? var 
			if val =~ /^true|false$/
				@variables[var] = 'false'
			elsif val =~  /^\d+$/ 
				@variables[var] = '0'
			elsif var =~ /^is_/
				@variables[var] = 'false'
			elsif val =~ / and / || val =~ / or / || val =~ /[=><]/
				@variables[var] = 'false'
			elsif val =~ / \+ / || val =~ / \* / || val =~ / - / || val =~ / \/ / 
				@variables[var] = '0'
			else
				@variables[var] = '""'
			end
		end
	end

	def to_choicescript
		@passages.map(&:to_choicescript).join("\n")
	end
end