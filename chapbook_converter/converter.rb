#! /usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'story'
require 'startup'
require 'runner'

if (["-h", "--help"].include? ARGV[0]) || ARGV.length < 2
	puts """
	Usage: [-v|--verbose] [cs_install_path=PATH] ./converter.rb my-twine-game.twee my_choicescript_directory 'Start Passage' ['General Functions Separator Passage']
    """
    exit 0
end

$verbose = ARGV.delete('-v') || ARGV.delete('--verbose')

if ARGV.any? {|a| a =~ /cs_install_path=(.*)/ }
	cs_install_path = $1
	ARGV.delete("cs_install_path=#{cs_install_path}")
end

infile = ARGV[0]
outdir = ARGV[1]
start = ARGV[2]


twee = File.read(infile)
puts "read #{infile}, got #{twee.lines.length} lines" if $verbose

story = Story.new twee, $verbose
puts "created story with #{story.passages.length} passages" if $verbose
outtext = story.to_choicescript
	
# TODO handle startup.txt and multiple chapters
outfile = "#{outdir}/chapter_1.txt"
puts "writing #{outtext.lines.length} lines to #{outfile}" if $verbose
File.write(outfile, outtext)

startup = Startup.new story
puts "writing startup.txt" if $verbose
File.write("#{outdir}/startup.txt", startup.to_choicescript)

if cs_install_path
	puts "writing runner bash script"
	runner = Runner.new(outdir, cs_install_path)
	File.write("#{outdir}/../run-choicescript.sh", runner.to_bash_script)
end

puts "finished" if $verbose




