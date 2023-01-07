# Jub Jub

**📢 - This is still somewhat work in progress. Some parts are missing 👀. Dec 2022**

Star Wars Battlefront (2004 / Classic) easteregg research

<img src="images/easteregg.png" width="100%">

---

## Disclaimer

I am by all means no professional researcher or hacker or whatever.  
I made this research (early 2020) with best of my knowledge, so if you find something odd, please let me know!  

## Motivation

- Battle front was my first mutliplayer game (ca. 2010 or 2011)
- The game somehow introduced me to computer stuff
  - Clan Websites
  - Creating maps
  - Modding game files
  - Messing around with game memory
- Curious since the first time I saw the easteregg
  - Was it intended or a bug?
  - How does it work and why?
- General interest in reverse engineering

## Some facts about the easteregg

- Profile name has to be exactly: `Jub Jub`
- It only works in singleplayer. Even as server host, the soldier models are normal.
- It does still work with the Steam-Version of the game
  - It seems they have added some kind of anti debug thing
  - https://github.com/ricardonacif/steam-loader

## Results

![disassembler](images/Jub_Jub_research_pt1.png)

A thought I had was: Maybe it has something to do with the profile file, since the easteregg depends on the profile name.  
Renaming these files and/or changing the bytecodes with a hexeditor does corrupt the profiles.  
I assume that there must be some kind of checksum in the profile file to prevent this.

Comparing two profiles that are identical except for their names:
![profile1](images/Jub_Jub_research_profiles_1.png)

Having only the difficulty changed in one profile:
![profile2](images/Jub_Jub_research_profiles_2.png)

- Hash algorithm: [Fowler–Noll–Vo](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function#The_hash)
  - See simle C# implementation here [fnv-algo.cs](fnv-algo.cs)

## Resources

- Assembly: <https://www.cs.yale.edu/flint/cs421/papers/x86-asm/asm.html>
- Flag Register: <https://en.wikipedia.org/wiki/FLAGS_register>
- Status Register: <https://en.wikipedia.org/wiki/Status_register>
- <https://stackoverflow.com/questions/62778926/third-operand-of-imul-instruction-is-a-memory-address-what-was-its-original-val>

## Tools used

- [Cheat Engine](https://www.cheatengine.org/)

## Thanks

- DarkByte for Cheat Engine
- Pandemic and LucasArts for that fantastic game
- [Psych0fred](http://secretsociety.com/forum/display_forum.asp) for providing so much to the modding community
- [SWBFGamers.com](http://www.swbfgamers.com/)
- CherryDT for answering my StackOverflow question ([see resources](#Resources))
- Markdeagle for unintentionally waking my interest in computer science (and actually metal music, too \m/)
- To my buddy Jay

## Misc

```none
Viathan Profile: EAX = 3520CC84
Jub Jub Profile: EAX  = C6961FF7
Battlefront.exe+1F71C5 - 3D F71F96C6 - cmp eax,C6961FF7
```







char boon root is adjusted as they would just stick in the ground otherwise
tat_inf_jawa along with bone information is present as static address.
other statics are only humanoid like vader, luke etc
changing tat_inf_jawa to all_inf_lukeskywalker seems to be working
maybe we can swap the model using mods
it seems the geometry is hardcoded and not actually using the model found in the side.lvl files

spine length?
Battlefront.exe+132766 - 68 E47A6A00           - push Battlefront.exe+2A7AE4 { ("bone_a_spine") }
Battlefront.exe+13276B - C7 07 FFFFFFFF        - mov [edi],FFFFFFFF { -1 }
Battlefront.exe+132771 - C7 47 04 FFFFFFFF     - mov [edi+04],FFFFFFFF { -1 }
Battlefront.exe+132778 - E8 03EAECFF           - call Battlefront.exe+1180

video

