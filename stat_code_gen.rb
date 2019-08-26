#! /usr/bin/env ruby

unless (ARGV.count > 2)
  puts """Usage: ./stat_code_gen.rb <stat_type> <stat1> <stat2> [<stat3>...]

  Example: ./stat_code_gen.rb primary canny careful deep daring learned 

           Run this, copy into startup.txt, then in your choicescript you can do:  
                *gosub_scene startup set_high_and_low_primary
                The highest stat is ${highest_primary_name}, with index ${highest_primary}
  """
end

#
# Code generation
#

def terminus var, prefix, pair, resolve
  "#{prefix}  *set #{var} #{pair[1]}\n#{prefix}  *set #{var}_name \"#{pair[0]}\"\n#{prefix}  #{resolve}\n"
end

def generate_highlow stats, indent, op, var, resolve
  prefix = " " * (indent * 2)
  (a, b, *rest) = stats
  if rest.size > 0
    left_branch = generate_highlow ([a] | rest), indent + 1, op, var, resolve
    right_branch = generate_highlow ([b] | rest), indent + 1, op, var, resolve
  else
    left_branch = terminus(var, prefix, a, resolve)
    right_branch = terminus(var, prefix, b, resolve)
  end
  "#{prefix}*if #{a[0]} #{op} #{b[0]}\n#{left_branch}#{prefix}*else\n#{right_branch}"
end  

stat_type = ARGV.shift 
stats = ARGV.each_with_index.map{|k, v| [k, v + 1]}.to_a

explanation = stats.map{|stat, n| "#{n} is #{stat}" }.join(", ")

puts """
******************************************************  
***  Code for lowest and highest #{stat_type} stats:

*********************************************************
*** Place this section in startup.txt, before \"*finish\"

*comment lowest/highest_#{stat_type}: #{explanation}
*create lowest_#{stat_type} 0
*create lowest_#{stat_type}_name \" \"
*create highest_#{stat_type} 0
*create highest_#{stat_type}_name \" \"

*********************************************************
*** Place this section in startup.txt, after \"*finish\"

*comment subroutine to find best and worst #{stat_type} stats
*label set_high_and_low_#{stat_type}
#{generate_highlow stats, 0, ">", "highest_#{stat_type}", "*goto set_lowest_#{stat_type}"}
*label set_lowest_#{stat_type}
#{generate_highlow stats, 0, "<", "lowest_#{stat_type}", "*return"}

  """
