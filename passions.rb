#! /usr/bin/env ruby

#
# Unfinished experimental tool for a relationship model 
# where every NPC has a 3-axis ardor/admiration/trust relationship
# with the PC
#

if (ARGV.count == 0) || (['--help', '-h'].include? ARGV[0])
  puts """Usage: ./passions.rb [--startval X,Y,Z] <char1> [<char2> <char3>...]

  Example: ./passions.rb shenouda namnah dawud

           --startvals: where ardor, admiration, & trust should begin (default 0,20,20)

           Creates tripartate passion variables for characters
           with whom you have impassioned relationships, and 
           helper functions to quickly analyze those relationships
  """
  exit 0
end


def as_sym charname
    charname.gsub('-', '').downcase.to_sym
end


startvals = [0, 20, 20]
if ['--startval', '-s'].include? ARGV[0]
    ARGV.shift
    startvals = ARGV.shift.split(",").map(&:to_i)
    unless startvals.count == 3
        puts "ERROR: startvals should have the format X,Y,Z: got #{startvals}"
        exit 1
    end
end

stats = {ardor: 'intense longing or desire', admiration: 'admiration', trust: 'trust'}
startvals = Hash[stats.keys.zip startvals]

puts startvals

charsyms = ARGV.map{|c| as_sym c}

stops = [10, 20, 30, 45, 65, 100]
stop_words = %w{lowest low meh mid high highest}
(ardor_stops, admire_stops, trust_stops) = stats.keys.map do |s|
    Hash[stop_words.map{|w| "#{w}_#{s}".to_sym}.zip stops]
end

relations = {
    lowest_ardor: {
        lowest_admiration: {
            lowest_trust:  "utterly despises you, as a vile dog with no honor.",
            low_trust:     "utterly despises you.",
            meh_trust:     "despises you.",
            mid_trust:     "considers you beneath notice.",
            high_trust:    "has little love for you.",
            highest_trust: "admits you are useful."

        },
        low_admiration: {
            lowest_trust:  "reviles you, as a dog with no honor.",
            low_trust:     "does not like or trust you.",
            meh_trust:     "dislikes you.",
            mid_trust:     "has no particular regard for you.",
            high_trust:    "has little regard for you, but considers you reliable.",
            highest_trust: "has scant regard for you, but considers you useful."
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    },
    low_ardor: {
        lowest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        low_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    },
    meh_ardor: {
        lowest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        low_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    },
    mid_ardor: {
        lowest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        low_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    },
    high_ardor: {
        lowest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        low_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    },
    highest_ardor: {
        lowest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        low_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        meh_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        mid_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        high_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        },
        highest_admiration: {
            lowest_trust:  "",
            low_trust:     "",
            meh_trust:     "",
            mid_trust:     "",
            high_trust:    "",
            highest_trust: ""
        }
    }
}


puts "======== in startup.txt: ======="
charsyms.each do |c|
    puts "\n*comment passion variables for #{c} (how much #{stats.keys.join(", ")} #{c} feels for the PC)"
    stats.each do |q, desc|
        puts "*create  #{c}_#{q} #{startvals[q]}"
    end
    puts "\n*comment #{c}_fate: 1 is haven't met them, 2 is actively relating, 3 is out of the picture, 4 is dead or destroyed"
    puts "*create #{c}_fate 1"
    puts "\n*comment for stats display:"
    puts "*create #{c}_textual_like \"\""
end


def p_indent lvl
    print ' ' * (lvl * 4)
end


def ifblock stat, val, index=999
    "*#{(index > 0) ? "else" : ""}if (#{stat} < #{val})"
end

ardor_if = -> (ard_v) { "*elseif (ardor < #{ard_v})" }
admire_if = -> (adm_v, i) { "*#{(i > 0) ? "else" : ""}if (admire < #{adm_v})"
}
trust_if = -> (trs_v, i) { 
    "*#{(i > 0) ? "else" : ""}if (trust < #{trs_v})"
}

puts %Q{
*comment stat descriptions for passion relationships
*label set_passion_relation_text 
*params character
*if collapsible
    *temp fate {"${character}_fate"}
    *temp ardor {"${character}_ardor"}
    *temp admire {"${character}_admiration"}
    *temp trust {"${character}_trust"}
    *temp out_var "${character}_textual_like"

    *if (fate = 1)
        *set {out_var} "???"
    *elseif (fate > 3)
        *set {out_var} "is no more."
}
ardor_stops.each do |ard, ard_v| 
    p_indent 1
    puts ifblock("ardor", ard_v)
    admire_stops.each_with_index.map do |(adm, adm_v), i|
        p_indent 2
        puts ifblock("admire", adm_v, i)
        trust_stops.each_with_index.map do |(trs, trs_v), j|
            p_indent 3
            puts ifblock("trust", trs_v, j)
            p_indent 4
            puts "*set {out_var} \"#{relations[ard][adm][trs]}\""
        end
    end
end
puts %Q{
*return


======= in choicescript_stats.txt: ==============

#{ARGV.map do |c|
    "*gosub_scene startup set_passion_relation_text \"#{c}\""
end.join "\n"}

[b]Relationships[/b]:

#{ARGV.map do |c|
    """
*if (#{as_sym c}_fate > 1)
    *stat_chart
        text #{as_sym c}_textual_like [b]#{c}[/b]"""
end.join "\n"}

}








