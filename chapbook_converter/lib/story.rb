require 'link'
require 'passage'

class Chunk
	attr_reader :title, :lines

	def initialize opening, story
		@story = story
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
		LabeledPassage.new @label, @lines, @story, verbose
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
					if chunk.title == 'StoryTitle'
						puts "StoryTitle chunk contains: #{chunk.lines.first}" if @verbose
						@title = chunk.lines.first.chomp
					elsif chunk.title != 'StoryData'
						@chunks.push chunk
					end
				end
				chunk = Chunk.new line, self
			else
				chunk.add line if chunk
			end
		end

		@passages = @chunks.map{|c| c.as_labeled_passage @verbose}

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