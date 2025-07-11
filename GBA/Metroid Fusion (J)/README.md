# Metroid Fusion (J) Autosplitter

## Awknowledgements

- u/_Tayx for the [base splits with icons for Live Split](https://www.reddit.com/r/Metroid/comments/7uiobn/fusion_speedrunners_just_made_some_cool_splits/)
- All the DataCrystal contibutors to the [Fusion RAM map page](https://datacrystal.tcrf.net/wiki/Metroid_Fusion/RAM_map)
- Bizhawk devs that make it all possible

## Usage

1. Launch LiveSplit and load up the splits. You can use your own splits if you want, but I did add a Sector 4 100% before Wave which is not a normal split in most 100% splits.
1. Launch BizHawk. Then in the menu bar open up Tools > Lua Console
1. Open up the Lua/GBA/MetroidFusion_AutoSplitter.lua ()
1. Play the game as usual. The splits will reset when you reset, progress, and finish as you play the game. 

The Lua console will also show you your completion in real time. Useful for hooking into OBS if you have a little bit of Lua skill.

## Modification

I recommend starting changes with `splits` array if modifying for another category, should be just deleting entries for matching any% splits. There are three types of possibly useful operands on these if you're looking to add more splits; "bit_and" which you can use on the binary flags for Samus' inventory and other bitwise flags. "eq" for just straight up checking a value. And "transform" for when one value strictly becomes another, useful for cutscenes and menus.

## Tools

The `GBA/State` folder contains all the test cases for the base splits. 

The `Tools` folder contains the RAM watch table I used to build this with labelled notes and in a format that's helpful for my use at least. I recommend checking the RAM map for the values, but their addresses are off, I imagine that's because of region differences.