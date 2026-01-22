class Startup

	attr_accessor :title, :author, :num_chapters

	def initialize story
		@story = story
	end


	def declarations
		{ collapsible: true } 
	end

	def join sections
		sections.map do |s| 
			section = (s.is_a? Array) ? s : [s]
			section.map { |line| line + "\n" }.join
		end.join "\n"
	end

	def meta 
		["*title #{title}",
         "*author #{author || 'Anonymous'}"]
    end

    def scenes
    	["*scene_list"] + @story.chapters.map{|c| "  #{c}"}
    end

    def declarations
    	@story.variables.map{|dt,dd| "*create #{dt} #{dd}"}
    end

	def to_choicescript
		join([meta, scenes, declarations])
	end
end