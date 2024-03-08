#! /usr/bin/env ruby

#
# Benjamin Rosenbaum 2024 CC-By-SA
#
# This is a proofreading script for ChoiceScript games. When run in
# your source files directory, it finds cases where you have
#  a) forgotten to balance your (), {}, or []
#  b) forgotten to enclose a variable containing an underscore in ${} or @{} 
#  c) used ".." which probably wants to be either "..." or "."
#
# It ignores startup.txt and choicescript_stats.txt, and comments, bug 
# assertions, and lines with TODO, DEBUG or FINAL_STATS.
#

# You can run this in your current directory, or pass in a path as an argument 
PROJECT_PATH = ARGV[0] || './'

# If you have lines that intentionally contain unbalanced parentheses, list them here, and they will be ignored. (This generally happens when some *if code splits a parenthetical phrase)
$known = [
 'you always feel a little odd about being counted among the required ten men',
 'Perhaps these things are just projections of your mind. Maybe',
 'that German philosopher',
 'universe…who knows? Anyway…)',
 '(But of course, ${endearment}, it\'s only a dream.',
 'perhaps that\'s not, in fact, just Ekaterina speaking?',
 'His casual disdain, ${endearment}, in the face of everything',
 'made it clear to the point of being somewhat thickheaded',
 'Then again, given that you have the soul of a woman, maybe',
 'because she had the soul of a man?)',
 'shouldn\'t? It\'s confusing.)',
 'real!)',
 'real...are they?)',
 'that controls her?)',
 'also, somehow, Efrayim?)',
 'full of bitterness; you have no words.)',
 'I would never say that. But some might...)',
]

def mismatch line, opener, closer
	line.count(opener) != line.count(closer)
end

# underscores that are not in dereferenced variables look weird
def looks_weird section
	section.split.map{|x| x.split("|")}.flatten.reject do |element| 
		element.include? "{"
	end.any? do |element|
		#puts "funky element #{element}" if element.include? "_"
		element.include? "_"
	end
end

def funky line
	line = line.split(":")[2..].join(":")
	if line.include? "*"
		false
	elsif line.include? "@{("
		pieces = line.split "@"
		pieces.any? do |piece|
			if piece.start_with? "{("
				p = 0
				index = 0
				piece.split('').each do |c|
					p += 1 if c == "(" 
					p -=1 if c == ")" 
					break if (p == 0 && c == " ") && (index > 1)
					index +=1
				end
				looks_weird piece[index..]
		    else
		    	looks_weird piece
		    end
		end
	else
		looks_weird line
	end
end

def find_issues content
	ignore_technical(content.each_line).select do |l|
		unmatched = mismatch(l, "(", ")") || mismatch(l, "{", "}")
		(unmatched || funky(l)) && !($known.any? {|kn| l.include? kn })
	end.compact
end

def ignore_technical input
	input.reject do |line| 
		['TODO', '*bug', '*comment', '*create', 'DEBUG',
		 '*temp', 'FINAL_STATS', 'startup.txt',
		 'choicescript_stats.txt'].any? do |w| 
		 	line.include? w 
		 end
	end
end

lines = find_issues `grep -n . #{PROJECT_PATH}*.txt`

if ARGV[0] == "--test"
	puts "Test 1:"
	puts (find_issues "spring-in-the-shtetl/01_the_market.txt:16:hey best_friend what's up\nspring-in-the-shtetl/01_the_market.txt:17:yo")
else
	puts lines.length == 0 ? "*** No new mismatched lines found ***" : "---------\nFound unbalanced tokens in the following lines:\n#{lines}"
end


broken = `grep -n "\.\." spring-in-the-shtetl/*.txt | grep -v "\.\.\."`.split("\n")
if (broken.length > 0)
	puts "Found incomplete ellipses/doubled periods in the following lines: "
	puts broken.join("\n")





