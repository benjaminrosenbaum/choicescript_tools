#! /usr/bin/env ruby

# playthroughs.rb -- creates multiple full-text-output local files containing
# playthroughs of your game, and a CSV file of various stats you output, so 
# you can search that file for various combinations of stats, and then read 
# through the corresponding playthrough output.
#
# If run with the -g or --gen flags, it instead outputs the code you 
# should insert near the end of your game to capture the values of each
# playthrough.

# Constants - Override these variables!
# we assume you are developing in one directory and then copying
# your files to the standard github choicescript project for compilation
# set DEVDIR to wherever your project is, PROJNAME the name of the directory 
# within that directory that contains your ".txt" files, and CSDIR to your local copy
# of choicescript
DEVDIR = "/Developer/bitbucket/cog"
CSDIR = "/Developer/github/choicescript"
PROJNAME = "spring-in-the-shtetl"

HOME = `cd ; pwd`.chomp

if (["-h", "--help"].include? ARGV[0])
	puts """
	Usgage: playthroughs.rb --gen
	           outputs code to insert into choicescript to capture values of each playthrough
	        playthroughs.rb --range MIN_MAX [dump-dir [stats-file]]
	           runs the specific playthroughs in the given range, overwrites their files in 
	           the <dump-dir> ONLY, and updates only those rows in <stats-file>.csv 
	        playthroughs.rb [--limit MAX] [--resume-at MIN] [dump-dir [stats-file]]
	           runs all playthroughs up through MAX, overwrites all files in 
	           the dump-dir, and (unless resuming) creates a new <stats-file>.csv 

	"""
	exit 0
end

if (ARGV[0] == "-g") || (ARGV[0] == "--gen")
	STARTUP = "#{HOME}#{DEVDIR}/#{PROJNAME}/startup.txt"
	cmd = "grep -E '^.create (.*?) (\\d+)' #{STARTUP} | cut -d ' ' -f 2"
	vars = `#{cmd}`.chomp.split("\n")
	if vars.length < 1
		puts "Error: could not find any numeric variables in your startup.txt file. Are you sure it is located at #{STARTUP}?"
		exit 1
	end
	
	puts """    ********************************
    Add the following to startup.txt:

    *create do_gather_stats false

    ********************************
    Insert the following code near the end of your game:

*if do_gather_stats  
    *fake_choice
        # FINAL_STATS_NAMES :#{vars.join(",")}
    *fake_choice
        # FINAL_STATS_VALS :#{vars.map {|s| "${#{s}}"}.join(",")}
	"""
	exit 0
end

range = 1..50001
overwrite_stats = true
resuming = false

if ((ARGV[0] == "-l")  || (ARGV[0] == "--limit"))
	ARGV.shift
	min = 1
	lim = ARGV.shift.to_i
	if (ARGV[0] == "--resume-at")
		resuming = true
		ARGV.shift
		min = ARGV.shift.to_i
	end
	range = min..lim

elsif (ARGV[0] == "-r")  || (ARGV[0] == "--range")
	overwrite_stats = false
	ARGV.shift
	range_str = ARGV.shift
	elems = range_str.split("-").map(&:to_i)
	if elems.length > 1
		if (elems[1] <= elems[0]) || (elems.length > 2)
			puts "Invalid range #{range_str}"
			exit 1
		end
		range = elems[0]..elems[1]
 	elsif elems[0] != 0
 		range = elems[0]..elems[0]
    else
    	puts "Failure to parse #{range_str} (#{elems}) as a range"
    	exit 1
    end
else
 	puts "Using default range #{range}; for a custom range use \"--range <X>-<Y>\" (this will not overwrite the stats file)"
end

#STATS = "#{HOME}#{DEVDIR}/stats.csv"
DUMP = "#{HOME}#{DEVDIR}/#{ARGV[0] || "dump"}"
LIVESTATS = "#{HOME}#{DEVDIR}/#{ARGV[1] || "live_stats"}.csv"
FAIL = "#{DUMP}/failures.html"
TMP = "#{DUMP}/tmp.csv"
TMP2 = "#{DUMP}/tmp2.csv"
# weirdly, the seed is not the same if we use the http: randomtest, so we need to open files directly.
URL_PREFIX = "file://#{DUMP}/"
URL_SUFFIX = ".txt"


`mkdir -p #{DUMP}`

def sed_ensure prop, val
	"s/\*create #{prop} #{!val}/\*create #{prop} #{val}/"
end

def sed_comment_out phrase
	"s/#{phrase}/\*comment #{phrase}/"
end

def retrieve_values_from text, iteration, url
	lines = text.each_line.select{|l| l.include? "FINAL_STATS_VALS"}
	(lines.size > 0) ? "#{iteration}:#{lines[0].partition(":")[2].chomp},#{url}\n" : nil  
end

# this makes sure that:
# -  the constant "do_gather_stats" is set to true (you can use this to conditionally 
#    output a line beginning with "FINAL_STATS_VALS:", which will get aggregated into live_stats.csv)
# -  the constant "debug_jump" is set to false, to avoid any short-circuits you have conditionally
#    added for debugging
# - the dashingdon special command *sm_init is commented out.
sed_cmds = "#{sed_ensure "do_gather_stats", true} ; #{sed_ensure "debug_jump", false} ; " +
		   "#{sed_ensure "extra_debugging", true} ; #{sed_ensure "in_beta_test", true} ; " +
		   "#{sed_ensure "override_true_name_for_test", true} ; " + 
           "#{sed_ensure "*create verbose_stats", true} ; #{sed_comment_out "\*sm_init mygame"} ;"

sed_run = "sed -I .bak '#{sed_cmds}' #{HOME}#{CSDIR}/web/mygame/scenes/startup.txt"

puts "running #{sed_run}"
`#{sed_run}`

OPTS = "showText=true showChoices=true avoidUsedOptions=true"
RT = "cd #{HOME}#{CSDIR} ; node randomtest.js" 

prev = Time.now
orig = prev

print "doing playthroughs"
puts "resuming interrupted run from #{range.begin}" if resuming
puts ", writing errors to #{FAIL} and rows provisionally to #{TMP}" if overwrite_stats
puts ", output files to #{DUMP}"


titles = ""
#titles = `head -1 #{STATS}`
#tn = titles.split(",").size
`rm -f #{TMP}; touch #{TMP}` if (overwrite_stats && (!resuming))
`rm -f #{TMP2}; touch #{TMP2}`
`echo "<p>The following playthroughs have errors:</p><ul>" > #{FAIL}` if (overwrite_stats && (!resuming))

tn = 0
range.each do |n|
	puts "seed=#{n}"
	f = "#{DUMP}/#{n}.txt"
	`#{RT} num=1 #{OPTS} seed=#{n} > #{f}`

	if n == range.begin
		titles = `grep FINAL_STATS_NAMES #{f} | cut -d : -f 2-`.chomp
		tn = titles.split(",").size
		if (tn < 1)
			puts "ERROR: no stats found in #{f}. Run ./playthroughs.rb -g and add the resulting code near the end of your game."
			exit 1
		end
		puts "found #{tn} titles in #{f}"
	end

	coda = `tail -50 #{f}`
	failure = coda.include? "RANDOMTEST FAILED"
	url = "#{URL_PREFIX}#{n}#{URL_SUFFIX}"

	puts "(playthrough #{n} failed...results at #{url})" if failure
	if overwrite_stats
		if failure
			File.write(FAIL, "<li><a href='#{url}'>#{n}</a>\n", mode: "a+") 
			File.write(TMP, "#{n}:#{"0," * (tn-1)}0\n", mode: "a+")
		else
			values = retrieve_values_from(coda, n, url)
			if values
				File.write(TMP, values, mode: "a+") 
			else
				puts "No values found for #{f}!"
			end
		end
	else
		values = retrieve_values_from(coda, n, url)
		File.write(TMP2, values, mode: "a+")
	end

	if ((n % 1000) == 0)
		curr = Time.now
		elapsed = curr - prev
		prev = curr
		remaining_intervals = (1.0 - ((n * 1.0) / range.max)) * 50 
		expected = curr + (elapsed * remaining_intervals) 
		puts "Expected finish: #{expected}"
 	end
end

unless overwrite_stats
	excludes = range.map{|n| "grep -vE '^#{n}:'"}.join("|")
	puts "Updating affected rows of #{LIVESTATS} from #{TMP2} via exclusions #{excludes}"
	`cat #{TMP} | #{excludes} >> #{TMP2}; sort -h #{TMP2} > #{TMP}`
end
puts "Finished; now to write #{LIVESTATS} from #{TMP}"
`cp #{LIVESTATS} #{LIVESTATS}.bak`
File.write(LIVESTATS, "#{titles.strip},URL\n")
`sort -h #{TMP} | cut -d : -f 2- >> #{LIVESTATS}`
