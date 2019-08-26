# choicescript_tools
Some helpful scripts for use with ChoiceScript

## stat_code_gen.rb

This tool requires Ruby to be installed on your machine. You can run it from the command line ("shell" in Unix, "Terminal" on a Mac). 

Run this tool to generate some ChoiceScript code to find out, at the point where you use it in your code, what the PC's highest and lowest stats of a particular kind are.

For instance, say your primary stats for your new game, Choice of the Hipster, are: cynical, snarky, emo, and sparkly.

You could run this command:

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

