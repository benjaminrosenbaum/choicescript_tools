#! /usr/bin/env ruby

if (["-h", "--help"].include? ARGV[0])
	puts """
	Usage: [-v|--verbose] converter.rb my-twine-game.twee my_choicescript_directory
    """
    exit 0
end

$verbose = ARGV.delete('-v') || ARGV.delete('--verbose')


