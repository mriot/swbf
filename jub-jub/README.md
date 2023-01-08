# Jub Jub

Star Wars Battlefront (2004 / Classic) easter egg research.

<img src="images/easteregg.png" width="100%">

## Table of contens

1. [Table of contens](#table-of-contens)
2. [Motivation](#motivation)
3. [Facts about the easter egg](#facts-about-the-easter-egg)
4. [Starting the research](#starting-the-research)
   1. [About savegame files in Battlefront](#about-savegame-files-in-battlefront)
   2. [Finding patterns within the profiles](#finding-patterns-within-the-profiles)
   3. [Conclusion on the profile theory](#conclusion-on-the-profile-theory)
5. [Another approach](#another-approach)
6. [The check](#the-check)
7. [The hashing function](#the-hashing-function)
   1. [Implementation](#implementation)
8. [Experiments](#experiments)
9. [Scripts and Cheat Table](#scripts-and-cheat-table)
10. [Conclusion](#conclusion)
11. [Resources](#resources)
12. [Thanks](#thanks)
13. [Disclaimer](#disclaimer)

---

## Motivation

Battlefront was my first game that I ever played in multiplayer back in ca. 2010.  
Over the years the game indirectly introduced me to several computer related topics such as webdesign, creating maps and modding game files, memory editing and reading and writing assembly just to name a few.  
When I was first told about this easter egg I was fascinated. I have never heard of such things before.

Immediately questions came to my mind like: Is this intentionally? A bug maybe? How does it work and why?

## Facts about the easter egg

- The name of the profile has to be exactly: `Jub Jub`
- It only works in singleplayer. Even as the server host, the soldier models are normal
- It still works even with the Steam-Version of the game

## Starting the research

Looking at the facts above, we can safely assume, that this is indeed not a bug.

My first guess was that it might has something to do with the profile or savegame file iteself, since the easter egg is related to the name.  

### About savegame files in Battlefront

The file extension is `.profile`.  
They reside inside the install directory in a folder called `SaveGames`  

The game seems to be storing several things in these files:

- The nickname of course
- Settings such as resolution, difficulty, etc
- campaign progress
- and more

Interestingly, the game does not use the actual name within the profile data but rather the filename to display the nickname.  
I assume they did this, that in case of a corrupted profile, they still can display the name in the selection screen.

![text file profile file](images/profile-selection.png)

Renaming or changing the contents with a hexeditor corrupts a profile so there's probably an integrity check in place.

![broken profile](images/corrupted-profile.png)

### Finding patterns within the profiles

In the following screenshot we're comparing two profile savegame files that are identical except for their name.  
They have the exact same settings, equal progress in compaigns and so forth.

The byte differences are listed side by side where the left column represents the "Jub Jub" profile and the right column represtens the "Abc Def" profile.  
Note that both names have a space at the same position and thus no difference at this particular byte.
![profile1](images/Jub_Jub_research_profiles_1.png)

In this comparisation I have only changed the difficulty of one savegame for otherwise completely identical profiles:
![profile2](images/Jub_Jub_research_profiles_2.png)

### Conclusion on the profile theory

At this point I was pretty confident, that the easter egg is not activated or controlled by the savegame file iteself.  
It could have been possible that the game sets a certain byte within the file upon profile creation but after comparing and experimenting with these files we can safely assume that this is not the case.

## Another approach

Moving on I decided to scan the memory of the game and search for a flag, a byte that indicates whether the easter egg is enabled.

...

## The check

![disassembler](images/Jub_Jub_research_pt1.png)
...

## The hashing function

- Hash algorithm: [Fowler–Noll–Vo](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function#The_hash)
...

### Implementation

#### In C\#

[fnv-algo.cs](fnv-algo.cs)
...

#### In JavaScript

...

## Experiments

videos/removing-spine-bone.mp4
...

## Scripts and Cheat Table

...

## Conclusion

- Surprised that the revered algo actually worked
- challenging: reversing of the algo - stack overflow question (glad there is such a forum)
- Happy to have lifted this mystery
- learned a lot and was fun

## Resources

- [Cheat Engine](https://www.cheatengine.org/)
- Hex Editor
- x86 Assembly: <https://www.cs.yale.edu/flint/cs421/papers/x86-asm/asm.html>
- <https://stackoverflow.com/questions/62778926/third-operand-of-imul-instruction-is-a-memory-address-what-was-its-original-val>

## Thanks

- Pandemic and LucasArts for SWBF
- DarkByte for Cheat Engine
- [Psych0fred](http://secretsociety.com/forum/display_forum.asp) for providing a lot to the modding community
- [SWBFGamers.com](http://www.swbfgamers.com/)
- CherryDT for answering my StackOverflow question ([see resources](#Resources))
- Markdeagle for unintentionally waking my interest in computer science (and metal 🤘)
- To my buddy Jay

## Disclaimer

...

---

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
