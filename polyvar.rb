#! /usr/bin/env ruby

if (ARGV.count == 0) || (['--help', '-h'].include? ARGV[0])
  puts %Q{Usage: ./polyvar.rb <name> <stat1> <stat2>...

  Example: ./polyvar.rb sympathies="Political Sympathies" fatimids="The Fatimid Caliphate" sunnis="The Sunni Revival" crusaders="The Latin Crusaders" jews="The Jews of Cairo"

           Creates auto-balanced polyvariables whose sum is always 100,
           including stat display code.
  }
  exit 0
end

pair_from = -> (arg) {
  arg.gsub('"', '').split('=')
}

(title, description)=pair_from.(ARGV.shift)

stats = Hash[ARGV.map{|arg| pair_from.(arg)}]


puts %Q{
==== in startup.txt: =====

*comment coordinated polyvariables for #{title} (#{description}):  
*comment these should always sum to 100.
}
stats.each do |t, d|
  puts %Q{
*comment #{t}: #{d}
*create #{t} #{100 / stats.length}}
end

puts "*finish\n"

first, *rest = *stats.keys
parenthesized = rest.map{|s| "(#{s}"}


total_calc = (parenthesized + [first]).join(" + ") + (')' * rest.size)

stats.each do |t, d|
  others = (stats.keys - [t])
  puts %Q{
*label set_#{title}_#{t}
*params value
*if collapsible
  *set #{t} %+{value}
  *temp gap (100 - #{total_calc}) / #{others.length}
  #{others.map{|o| %Q{
  *set #{o} +({gap})}}.join('')}
  *temp total #{total_calc}
  *if (total = 99)
    *set #{t} +1
  *elseif (total = 101)
    *set #{t} -1
  *else
    *bug "failed to balance polyvariable #{title} setting #{t} by ${value}: does not add up to 100"
*return

}
end

#  #{others.map{|o| "(#{o}"}.join(' + ')} + #{t}#{')' * others.size}




#puts title
#puts description
#puts stats


