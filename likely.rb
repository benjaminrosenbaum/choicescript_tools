#! /usr/bin/env ruby

if (ARGV.size == 0) or (ARGV.include? "--help")
	puts "Usage: likely [--if | --if2] [--multiselect, -m] [--html] [--partition, --p <partition_val>] <stat> [<runs>]"
	puts "       --if, --multiselect, and --html are alternative ways of displaying information"
	puts "       --if2 is like --if but ignores value=1, which is usally a 'not yet calculated' state"
	puts "       --partition aggregates the ranges above and below the partition_val"
	puts """       
				   Run this script when you are in the directory that holds test.coverage.

				   likely.rb hunts through your code for lines of the form:
				   *comment [variable name]: 1 is [defintion], 2 is [defintion], 3 is [defintion]...

				   You should put this comment line where you define the variable. e.g. in startup.txt.

				   These are called 'enumerated variables' and they are one possible alternative
				   to scalar ranges (0-100, how tough are you?) or booleans (true/false). Enumerated
				   variables let you have a legible list of certain outcomes. So if there are 7 different
				   romantic partners your MC could end up with, an enumerated variable partner_chosen
				   lets you capture that information in one place. They also work extremely well with 
				   ChoiceScript's multichoice @{} feature. This script allows you to quickly recall 
				   what the values are, and to see a rough estimate of their probabilities in randomtest
				   playthroughs.

				   If there is a test.coverage file in the current directory, likely.rb will draw 
	               probabilities from it. Note that these probabilities are inaccurate if the value
	               is reset multiple times in a single playthrough, so this works best for variables
	               that are set a single time.

                   The default 'runs' are 50000, what randomtest.js usually uses, but you can override
				   that number."""
	exit(0)
end

if (["--if", "--if2"].include? ARGV[0])
	$if = true
	$skipfirst = true if (ARGV[0] == "--if2")
	ARGV.shift
end

if ((ARGV[0] == "--multiselect") || (ARGV[0] == "-m"))
	if $if 
		puts "--if and --multiselect are incompatible options"
		exit 1
	end
	$multiselect = true
	ARGV.shift
end


if (ARGV[0] == "--html")
	if $if or $multiselect
		puts "--if, --multiselect, and --html are incompatible options"
		exit 1
	end
	$html = true
	ARGV.shift
end

if ((ARGV[0] == "--partition") || (ARGV[0] == "-p"))
	ARGV.shift
	$partition_val = ARGV.shift.to_i
end

filter_defs = ""

stat = ARGV[0]

runs = (ARGV.size > 1) ? ARGV[1].to_i : 50000


def get_stat_def stat
	definition = `grep "comment #{stat}:" randomtest-output.txt | tail -1`.chomp

	def_parts = definition.split(':', 3)

	unless def_parts.size == 3
		puts "Malformed definition: #{definition}" 
		exit 1
	end

	defs = Hash[def_parts[2].split(',').map do |d|
		d.gsub(" is ", "|").split('|')
	end.map {|k,*v| [k.to_i, v.join(' is ')]}]
end

#puts defs

def get_lines stat
	result = `grep "set #{stat}" randomtest-output.txt`.lines 
	result
end

defs = get_stat_def stat

quants = {}

# add up all the times the enum is set to a value in code, in test.coverage
lines = get_lines(stat) + ((stat.include? "final") ? get_lines(stat.gsub("final", "provisional")) : [])
quants = Hash[ lines.inject({}) do |a, q|
	if q =~ /(.*) (\d*):\s*\*set [A-Za-z_]* (\d*)/
		k = $3
		v = $2.to_i
		a[k] = (a[k] || 0) + v
	end
	a
end.map {|k,v| [k.to_i, v.to_f]}]

#puts quants[2]
#puts defs

if $html 
	puts "<p><b>#{stat}</b>"
elsif $multiselect
	print "@{#{stat} "
else
	puts "#{stat} values by likelihood:"
end

sum = 0

def pct_for val, runs 
	(((val || 0.0) * 100)/runs).round(2)
end

defs.each_with_index do |(k, v), index|
	pct = pct_for(quants[k],runs)
	sum = sum + pct
	if $if 
		next if $skipfirst && (index == 0)
		initial = (index == 0) || ($skipfirst && (index == 1))
		puts "*#{ initial ? "" : "else"}if (#{stat} = #{k})"
		puts "    *comment #{k}: #{v} (#{pct}%)"
		puts "    TODO"
	elsif $multiselect
		print "|" unless (index == 0)
		print "#{v}(#{pct}%)"
    else
    	print "      <br/>" if $html
		puts "  #{k} -  #{v}: #{quants[k]}(#{pct}%)"
    end
end
if $html
	puts "<br/>=#{sum.round(2)}%"
elsif $multiselect
	puts "}"
elsif $if
	puts "\*else"
	puts "    *bug \"invalid #{stat}=${#{stat}}\""
else
	puts "-----------\n sum: #{sum.round(2)}%"
end

def show_range from, to, amt, runs
	"#{from}-#{to}: #{amt} (#{pct_for(amt, runs)}%)"
end

if $partition_val
	(lower, rest) = quants.partition{|k, v| k < $partition_val}.map do |section|
		section.inject(0.0){|mem, (k,v)| mem + v}
	end
	puts "<br/><br/>" if $html
	puts (show_range 1, ($partition_val-1), lower, runs)
	puts "<br/>" if $html
	puts (show_range $partition_val, quants.keys.max, rest, runs)
end unless $if

puts "</p>" if $html




