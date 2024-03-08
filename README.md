# choicescript_tools
Some helpful scripts for use with ChoiceScript.

These tools require Ruby to be installed on your machine. You can run them from the command line ("shell" in Unix, "Terminal" on a Mac), usually from the directory where your .txt story files live.

* unbalanced.rb - print a proofreading report of unmatched brackets, bare variables, and broken ellipses.
* stat_code_gen.rb - generate ChoiceScript to find out the PC's best and worst stats at a given point in time.


## unbalanced.rb

Run this tool in the directory where your .txt files live.

```sh
ruby unbalanced.rb
```

It will show you some possible errors in your code:
* places you have ".." (you probably want "..." or ".")
* words with underscores in them that aren't inside ${} or @{} or in control statements like `\*if` or `\*goto`. These are probably variables you forgot to wrap. 
* Unbalanced brackets, like ( or { or [. You might actually want this if you are starting a parenthesis on one line and ending it on another (for instance, if there are multiple ways the parenthetical expression could end, controlled by `\*if/\*else`.) This isn't that common, but if you want you can edit the .rb file and tell it what lines to ignore.

## stat_code_gen.rb

Run this tool to generate some ChoiceScript code to find out, at the point where you use it in your code, what the PC's highest and lowest stats of a particular kind are.

For instance, say your primary stats for your new game, Choice of the Hipster, are: cynical, snarky, emo, and sparkly.

You might want some character that your PC interacts with to react in some way that is based on their high stat. For instance:

```
  *gosub_scene startup set_high_and_low_primary

  "Jehosephat!" says the beard-grooming salesperson, "that is certainly the most @{lowest_primary naive|overly earnest|complacent|unkempt} beard I have seen in all my career!"

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

...and get a separate stat function to figure out which of those are highest and lowest.

