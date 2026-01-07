#! /usr/bin/env ruby

# flowchart.rb -- draws a graph of your story's paths, based on annotations, using graphViz

# Instructions: Override these variables: DEVDIR, PROJNAME
# DEVDIR can be an absoulte path, or a paths relative to your home directory 
# using "~" to represent that directory.
#
# You can either set the CST_DEVDIR and CST_PROJNAME environment variables 
# in your shell, like this:
#    export CST_DEVDIR="/Developer/gamedev/myproj"
# ...or you can modify this file to change the defaults.
#
# PROJNAME should be the name of the directory within DEVDIR that contains your ".txt" 
# files.
#
# The graph output will be placed in DEVDIR/PROJNAME/maps/PROJNAME.png
#


if (["-h", "--help"].include? ARGV[0])
	puts """
	Usage: flowchart.rb [projname]

	    Draws a flowchart of your story's paths, based on annotations, using graphViz

	    Set up the CST_DEVDIR and CST_PROJNAME environment variables: CST_DEVDIR to point 
	    to your development directory, with your .txt files in a CST_PROJNAME directory 
	    within it. (You can also set the PROJNAME with the first command-line argument.)

	    You must have the graphViz \"dot\" utility installed. See https://graphviz.org

	    In your ChoiceScript code, add comments prefixed with a pipe character \"|\", 
	    showing transitions between labels with \"->\" and optionally, \"TODO\" and 
	    \"DOING\" states. Typically you'll want to add these comments right 
	    before significant labels:

	    *comment | finished_func -> choice_being_worked_on
	    *comment | finished_func -> choice_not_yet_started
	    *comment | finished_func -> choice_finished
	    *label finished_func
	    	*choice 
	    		# Do a thing.
	    			*goto choice_not_yet_started
	            # Do a different thing.
	    			*goto choice_being_worked_on
	    	    # Do something entirely different
	    	    	*goto choice_finished

		  *comment | choice_not_yet_started TODO
	    *label choice_not_yet_started
	    haven't gotten to this yet... 

	    *comment | choice_being_worked_on DOING
	    *label choice_being_worked_on
	    work in progress... 

	    *label choice_finished
	    Wow, that's different!  


	    The graph output will be placed in CST_DEVDIR/CST_PROJNAME/maps/CST_PROJNAME.png

	"""
	exit 0
end

def get_path envvar, default_path
	(ENV[envvar] || default_path).gsub(/~/, `cd ; pwd`.chomp)
end

# NOTE: Adjust these defaults if needed
DEVDIR = get_path 'CST_DEVDIR', "~/Developer/bitbucket/cog"
PROJNAME = ARGV[0] || ENV['CST_PROJNAME'] || "spring-in-the-shtetl"

# We will assume any .txt file in the DEVDIR/PROJECT directory is a chapter. If you 
# want to exclude any such files, you can list them here:
EXCLUSIONS = ["exclude_me.txt"]

MAPS = "#{DEVDIR}/maps"
#
#  Graph story nodes with graphviz
#

def subgraph txtdir, chapter
  name = chapter.split('.')[0] 
  commands = `grep '\*comment |' #{txtdir}/#{chapter} | cut -d "|" -f 2`
  commands.gsub!(' TODO', '[color=red,fontcolor=red]')
  commands.gsub!(' DOING', '[color=blue,fontcolor=blue]')
  """
    subgraph cluster_#{name} {
      label=\"#{name}\"
      #{commands}
    }
  """
end


def graph txtdir, chapters
"""
digraph {
  #{chapters.map{ |c| subgraph txtdir, c }.join("\n") }
}
"""
end

system("mkdir -p #{MAPS}")
chapters = `ls -1 #{DEVDIR}/#{PROJNAME} | grep txt | sort`.split("\n") - EXCLUSIONS 
IO.write("#{MAPS}/#{PROJNAME}.txt", graph("#{DEVDIR}/#{PROJNAME}", chapters))
system("cd #{MAPS}; dot -Tpng < #{PROJNAME}.txt > #{PROJNAME}.png") 
system("cd #{MAPS}; open #{PROJNAME}.png") 

