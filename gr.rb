#! /usr/bin/env ruby

# if your text files are in a subdirectory, override this with the path to that directory.
PROJECT_PATH = "."

if (ARGV.size == 0) or (ARGV[0] == "") or (ARGV.include? "--help")
	puts "Usage: ./gr.rb <text-sought> [<number of context lines around>]"
    puts ""
    puts "Example: ./gr.rb \"lost monocle\" 44  - shows 44 lines before and after each instance"
    puts "          of the string \"lost monocle\", emphasizing that phrase so it's easy to find,"
    puts "To make this more usable, put gr() {clear; ./gr.rb \"$1\" $2 | more} in your ~/.zshrc or equivalent."
    exit 0
end

sought = ARGV[0].upcase

`grep -ni#{ARGV[1]} "#{sought}" #{PROJECT_PATH}/*`.each_line.map do |l| 
	puts l.gsub(/#{sought}/i, "#### #{sought} ####")
end 
