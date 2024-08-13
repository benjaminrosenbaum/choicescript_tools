# choicescript_tools
Some helpful scripts for use with ChoiceScript.

These tools require Ruby to be installed on your machine. You can run them from the command line ("shell" in Unix, "Terminal" on a Mac), usually from the directory where your .txt story files live.

* unbalanced.rb - print a proofreading report of unmatched brackets, bare variables, and broken ellipses.
* playthroughs.rb - run multiple randomtests, capturing the output and buildiung a file of stats which you can parse to find interesting examples of playthroughs to read from start to finish.
* stat_code_gen.rb - generate ChoiceScript to find out the PC's best and worst stats at a given point in time.


## likely.rb

Run this tool, after doing a randomtest.js run with showCoverage=true and getting a randomtest-output.txt file, when your current directory is the directory with that file in it.

It will allow you to get various output about your enumerated variables, such as listings:

```
   % ./likely.rb efrayim_memory
   efrayim_memory values by likelihood:
     1 -  childhood stories: 10017.0(20.03%)
     2 -  rage in the tavern: 10003.0(20.01%)
     3 -  his argument with Menakhem: 9932.0(19.86%)
     4 -  him lurking in the woods: 9989.0(19.98%)
     5 -  him wandering the alleys: 10059.0(20.12%)
   -----------
    sum: 100.0%
   
```

...multiselect templates:

```
    % ./likely.rb -m efrayim_memory
    @{efrayim_memory childhood stories(20.03%)|rage in the tavern(20.01%)|his argument with Menakhem(  19.86%)|him lurking in the woods(19.98%)|him wandering the alleys(20.12%)}
```

...and if blocks:

```
    % ./likely.rb --if efrayim_memory
    efrayim_memory values by likelihood:
    *if (efrayim_memory = 1)
        *comment 1: childhood stories (20.03%)
        TODO
    *elseif (efrayim_memory = 2)
        *comment 2: rage in the tavern (20.01%)
        TODO
    *elseif (efrayim_memory = 3)
        *comment 3: his argument with Menakhem (19.86%)
        TODO
    *elseif (efrayim_memory = 4)
        *comment 4: him lurking in the woods (19.98%)
        TODO
    *elseif (efrayim_memory = 5)
        *comment 5: him wandering the alleys (20.12%)
        TODO
    *else
        *bug "invalid efrayim_memory=${efrayim_memory}"
```

## unbalanced.rb

Run this tool in the directory where your .txt files live.

```sh
ruby unbalanced.rb
```

It will show you some possible errors in your code:
* places you have ".." (you probably want "..." or ".")
* words with underscores in them that aren't inside ${} or @{} or in control statements like `*if` or `*goto`. These are probably variables you forgot to wrap. 
* Unbalanced brackets, like ( or { or [. You might actually want this if you are starting a parenthesis on one line and ending it on another (for instance, if there are multiple ways the parenthetical expression could end, controlled by `*if/*else`.) This isn't that common, but if you want you can edit the .rb file and tell it what lines to ignore.

## playthroughs.rb

This allows you to collect data on multiple randomtest playthroughs, find interesting variations, and then read the entire playthrough for that case.

(Warning: it can take a very long time to go through the default 50000 runs, and potentially take up a vast amount of space on your hard disk. For a complex game, you might want to let it run overnight.)

To use:

First, modify this script file to point at your own development and choicescript directories.

Then run `./playthroughs.rb --gen`

This will output some Choicescript code: a variable you must add to startup.txt, and two `fake_choice`s which capture all the numeric variables you define in your startup.txt file. Copy these into your game, at the end of the last chapter.

Then you can run `./playthroughs.rb`

This will create a directory called `dump` containing 50000 full-text playthroughs of your game, and a CSV file called live_stats.csv which lists the stats for each of those playthroughs.

**Example of use.** Let's say you have an enumerated variable called "what_you_promised_the_king" and another enumerated variable called "magic_power", and you want to see what a game would look like in the rare case that the first variable was 4 (meaning that you promised the king you'd investigate the matter of the missing orchid) and the second variable is 6 (meaning you know how to walk through walls). 

You could open the CSV file in a spreadsheet, filter on those values, look for an interesting playthrough based on the other values in the row... and then scroll to the rightmost column, which has the local URL of the file for that playthrough.

## stat_code_gen.rb

Run this tool to generate some ChoiceScript code to find out, at the point where you use it in your code, what the PC's highest and lowest stats of a particular kind are.

For instance, say your primary stats for your new game, Choice of the Hipster, are: cynical, snarky, emo, and sparkly.

You might want some character that your PC interacts with to react in some way that is based on their highest or lowest stat. For instance:

```
  *gosub_scene startup set_high_and_low_primary

  "Jehosephat!" says the beard-grooming salesperson, "that is certainly the
   most @{lowest_primary naive|overly earnest|complacent|unkempt} beard I
   have seen in all my career!"

```

To generate the code needed, you would run this command:

```sh
ruby stat_code_gen.rb primary cynical snarky emo sparkly
```

And the program would respond with the following, which you can cut and paste into your ChoiceScript:

```
******************************************************  
***  Code for lowest and highest primary stats:

*********************************************************
*** Place this section in startup.txt, before "*finish"

*comment lowest/highest_primary: 1 is cynical, 2 is snarky, 3 is emo, 4 is sparkly
*create lowest_primary 0
*create lowest_primary_name " "
*create highest_primary 0
*create highest_primary_name " "

*********************************************************
*** Place this section in startup.txt, after "*finish"

*comment subroutine to find best and worst primary stats
*label set_high_and_low_primary
*if cynical > snarky
  *if cynical > emo
    *if cynical > sparkly
      *set highest_primary 1
      *set highest_primary_name "cynical"
      *goto set_lowest_primary
    *else
      *set highest_primary 4
      *set highest_primary_name "sparkly"
      *goto set_lowest_primary
  *else
    *if emo > sparkly
      *set highest_primary 3
      *set highest_primary_name "emo"
      *goto set_lowest_primary
    *else
      *set highest_primary 4
      *set highest_primary_name "sparkly"
      *goto set_lowest_primary
*else
  *if snarky > emo
    *if snarky > sparkly
      *set highest_primary 2
      *set highest_primary_name "snarky"
      *goto set_lowest_primary
    *else
      *set highest_primary 4
      *set highest_primary_name "sparkly"
      *goto set_lowest_primary
  *else
    *if emo > sparkly
      *set highest_primary 3
      *set highest_primary_name "emo"
      *goto set_lowest_primary
    *else
      *set highest_primary 4
      *set highest_primary_name "sparkly"
      *goto set_lowest_primary

*label set_lowest_primary
*if cynical < snarky
  *if cynical < emo
    *if cynical < sparkly
      *set lowest_primary 1
      *set lowest_primary_name "cynical"
      *return
    *else
      *set lowest_primary 4
      *set lowest_primary_name "sparkly"
      *return
  *else
    *if emo < sparkly
      *set lowest_primary 3
      *set lowest_primary_name "emo"
      *return
    *else
      *set lowest_primary 4
      *set lowest_primary_name "sparkly"
      *return
*else
  *if snarky < emo
    *if snarky < sparkly
      *set lowest_primary 2
      *set lowest_primary_name "snarky"
      *return
    *else
      *set lowest_primary 4
      *set lowest_primary_name "sparkly"
      *return
  *else
    *if emo < sparkly
      *set lowest_primary 3
      *set lowest_primary_name "emo"
      *return
    *else
      *set lowest_primary 4
      *set lowest_primary_name "sparkly"
      *return
```

You wouldn't want to write all that yourself, so it's nice to have the program do it.

If, after doing the primary stats, you decide you want an additional set of stats for hipster enthusiasms, namely comics, craft_beers, indie_music and toast, you could run:

```sh
ruby stat_code_gen.rb enthusiasm comics craft_beers indie_music toast
```

...and get a separate stat function to figure out which of those are highest and lowest. (The function would be called `set_high_and_low_enthusiasm` and the variables `lowest_enthusiasm`, `lowest_enthusiasm_name`, etc.)

