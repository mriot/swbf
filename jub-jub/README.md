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
   1. [A short lesson about the stack](#a-short-lesson-about-the-stack)
   2. [A short lesson on x86 registers](#a-short-lesson-on-x86-registers)
   3. [Other interesting things in this algorithm](#other-interesting-things-in-this-algorithm)
   4. [Implementation](#implementation)
8. [The code that makes the easter egg have an effect](#the-code-that-makes-the-easter-egg-have-an-effect)
9. [Wrapping up](#wrapping-up)
10. [Scripts and Cheat Table](#scripts-and-cheat-table)
11. [Conclusion](#conclusion)
12. [Resources](#resources)
13. [Thanks](#thanks)

---

## Motivation

Battlefront was my first game that I ever played in multiplayer back in ca. 2010.  
Over the years the game indirectly introduced me to several computer related topics such as webdesign, creating maps and modding game files, memory editing and reading and writing assembly just to name a few.  
When I was first told about this easter egg I was fascinated. I have never heard of such things before.

Immediately questions came to my mind like: Is this intentionally? A bug maybe? How does it work and why?

## Facts about the easter egg

> "Jub Jub" ewoks saying bla bla bla

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

As it turned out, that was pretty easy to find. I checked which opcodes access this address.

## The check

I found this code:  
![set flag code](images/hash-compare-set-flag-no-comments.png)

First `EAX` is pushed onto the stack followed by a `call` instruction. This indicates, that the value of `EAX` is used within that function (i.e. passed as an argument).  

Lets set a breakpoint to find out what the value of `EAX` is before it's passed to the function.
![value of eax arg](images/value-of-eax-arg-no-comments.png)

Hmm, this looks like a memory address!

Lets check out what the value at that address is:
![profile name in memory](images/profile-name-in-memory.png)

Great! We found the profile name address!  
So `EAX` is holding the adress to our name and that is passed to the function.  
A quick look into that function reveals that it does some processing with the name.

> We will dive deeper into that function in the next step but for now we assume that that this function generates a hash for our profile name and that the result is stored in the `EAX` register.

After the `call` instruction, we can see a compare, that compares our hash in `EAX` with a hexadecimal number `C6961FF7`. Interesting.  Maybe it's the hash for "Jub Jub"?!  
To find out, I placed a breakpoint on that compare and picked the "Jub Jub" profile.

![eax contains hash](images/eax-contains-name-hash-no-comments.png)

**Nice**! As we can see, the value in `EAX` is the same as our magic number. :)  
For testing purposes I picked my main profile and this was the generated hash: `EAX: 3520CC84`.

Following the rest of the instructions we can see that apparently, the easter egg will be enabled for every profile for a brief moment before it is disabled on non "Jub Jub" profiles.  
The byte is unconditionally set to 1 directly after the compare and the next jump is only taken, when the hashes match. Essentially skipping the deactivation of the easter egg.

Now it's time to take a closer look at...

## The hashing function

![the hashing function](images/the-hashing-function.png)

At first glance it might look a little complicated so I added some comments to describe what I think is going on.

![the hashing func with comments](images/the-hashing-function-with-comments.png)

### A short lesson about the stack

First of all you might be asking why `ESP+4` is holding our `EAX` argument with the name address.  
`ESP` is the so called _stack pointer_. The _stack_ itself is basically a _Last In, First Out (LIFO)_ storage used (among other things) for passing arguments to functions.  
`ESP` holds the base pointer address of the stack.

Remember, before calling this function the game did `push EAX` placing the value of `EAX` on the stack.  
It was placed at the top or first position on the stack which is `ESP+0` or just `ESP`.  
The `+ NUMBER` part is the offset in bytes.

So why is our name address now, when we are inside the hashing function, at `ESP+4`?  
Because of the `call` instruction.  
`call` jumps to a function and that needs to return somewhere when it is done. The address to where it should return is stored on the stack as well. At the first position `ESP+0`, essentially pushing everything else on the stack further down.  
And since the return address is 4 bytes long, we need to retrieve our argument with `ESP+4`.

### A short lesson on x86 registers

After the first `je` you'll see the instruction: `mov cx,[edx]` with the comment describing that the first character of the name is put into `CX`.

As a 32 bit game it has access to several 32 bit (4 byte) registers, which are small super fast storage units on the CPU.  
These can be split into even smaller portions like this graphic illustrates:

<img src="images/x86-registers.png" width="500px" />

Image source: <https://www.cs.virginia.edu/~evans/cs216/guides/x86.html#registers>

So, what is our instruction doing?  
As we know, `EDX` is holding the address to our name. And by writing `[EDX]` (note the brackets) we access the **value** of the **memory address** `EDX` is holding.

`mov cx,[edx]` instructs the computer to take the **value** of the **address** and place it in `CX` which can only hold 2 bytes.  

After this instruction the `ECX` register looks like this:
![ecx holding first char](images/hash-func-first-char-in-ecx.png)

We ignore the first two bytes (`00 7F`) in the register since they were in there before.  

The bytes we care about are `00 4A` where `4A` is [ASCII](https://en.wikipedia.org/wiki/ASCII) for the letter "J". The first character of our name.  
The profile name is encoded in [Unicode](https://en.wikipedia.org/wiki/Unicode) more specifically in UTF-16. That makes `00` part of our ASCII charater "J" because we have two bytes for each character available.  
A unicode character that uses both bytes for example is the Euro € symbol: `20 AC`

<pre>
'J'  ->  U+00 4A
'u'  ->  U+00 75
'b'  ->  U+00 62
' '  ->  U+00 20
'J'  ->  U+00 4A
'u'  ->  U+00 75
'b'  ->  U+00 62
</pre>

In memory that looks like: ![name in memory](images/name-in-memory-detail.png)

### Other interesting things in this algorithm

After the second `je` instruction we see `mov eax,811C9DC5`. This hardcoded value in the context of a hashing algorithm is known as the "offset basis", and is used as the starting point for the hash calculation.

Further down we can find `69 C0 93010001 - imul eax,eax,Battlefront.exe+C00193` and this gave me a hard time.  
I was not able to understand the third operant but luckily there are helpful people on the internet as you can read in my [question on StackOverflow](https://stackoverflow.com/questions/62778926/third-operand-of-imul-instruction-is-a-memory-address-what-was-its-original-val). Thanks again CherryDT!

<details>
   <summary>👀 Screenshot of that question and answer</summary>

   ![asd](images/question-on-stackoverflow.png)
</details>

<pre>
811C9DC5 -> Offset basis
01000193 -> Prime number
</pre>

So after reversing the hashing alogrithm for hours and getting a headache about that `imul` we now know which alogrithm they used!

The [FNV-1a (Fowler-Noll-Vo hash function 1a)](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function#The_hash) is a non-cryptographic hash function that was developed in 1991.

A screenshot from Wikipedia shows both hardcoded values:
![fnv params](images/fnv-offset-basis-wikipedia.png)

### Implementation

#### In C\#

Here is the initial version of the reversed alogorithm: [fnv-algo.cs](fnv-algo.cs)

<details>
   <summary>👀 Show code</summary>

```cs
using System;

namespace BattlefrontNameHash {
    class Program {
        static void Main(string[] args) {
            start();
        }

        static void start() {
            Console.Write("Enter a name to generate the hash for: ");
            string input = Console.ReadLine();

            Console.WriteLine("=> Hash for {0} is {1}\n", input, generateHash(input).ToString("X"));
            start();
        }

        static uint generateHash(string input) {
            // Battlefront.exe+1F744B - test cx,cx
            if (input.Length <= 0) return 0;

            // Battlefront.exe+1F7450 - mov eax,811C9DC5
            uint hash = 0x811C9DC5; // base hash

            for (int i = 0; i < input.Length; i++) {
                // Battlefront.exe+1F7458 - xor eax,ecx
                hash ^= input[i];

                /*
                 * Here the third operand (source2) of imul got misinterpreted by the disassembler
                 * it is actually a prime number and not a memory address.
                 * If you add the base address (0x00400000) and 0xC00193, the result is 0x1000193
                 */
                // Battlefront.exe+1F745D - imul eax,eax,Battlefront.exe+C00193
                hash *= 0x1000193;
            }

            return hash;
        }
    }
}
```

</details>

#### In JavaScript

Just for fun I made a little Webapp with Svelte that lets you test the algorithm online.  
<link/to/website>

## The code that makes the easter egg have an effect

Now we know how the game determines wether the easter egg is active but how does it work?  
What does the code look like, that actually applies the easter egg?

To find the responsible code, I tracked which opcodes access the easter egg's status address.  
I found this section where a lot is going on so I added some comments:

![disassembler](images/Jub_Jub_research_pt1.png)

The last blue box is very interesting.

`tat_inf_jawa`? Is that the model that's being used?  
I was confused since the community (and I) always assumed that it would use the [Ewok](https://starwars.fandom.com/wiki/Ewok) model.  
And another question arised. We can use this easter egg on all maps and not only on those which load the required models. How does that work?

Using modding tools, I switched the model of the Jawa with the model of a Tusken raider:
![tusken](images/swapped-model-with-tusken.png)

Except for having baby tusken now, it didn't change anything at all. That means, the game is not using the actual Jawa model, that is stored (like most other models), in a .lvl file.

Well, maybe the model is "hardcoded" into the game executable? That would also explain why it works on every map.

To test this, I took a look into the .exe with a hex editor.  
![tat_inf_jawa in game exe](images/tat_inf_jawa-hexeditor.png)

And indeed, the name of the model is there. Apparently along with some bone information that is used to rig the soldiers?  
To find out if more models are available in the .exe I searched for `_inf_` and found those gentlemen:

![heroes and villians](images/other-models-in-exe.png)

Though none of them had similar bone information like our jawa model assiciated with them in the executable.

Nevertheless I tried to replace the jawa model with something else.  
No matter what I supplied, it always reverted to the normal model. I guess there is some errorhandling in place that just skips teverything if the necessary bones are missing.

Speaking of rigging. This is what happens if you remove the spine bone:

![no spine](images/no-spine.png)

[Here's a video](https://onedrive.live.com/embed?cid=5279059A682EC257&resid=5279059A682EC257%2175251&authkey=AGo1z1q_BvuOq8E)


Another interesting fact, they have adjusted the vertical character position, otherwise they would stick in the ground or hover in the air like this:

![char pos](images/adjusted-char-pos-from-0.6-to-3.0.png)
I set the position from 0.60 which is applied for Jub Jub to 3.0.

## Wrapping up

1. The game reads in the selected profile
2. Grabs the name
3. Generates the FNV hash
4. Compares it against the hash value of "Jub Jub" (which is 0xC6961FF7)
5. Sets a byte to 1 if the name is Jub Jub or a 0 if it is something else
6. While loading a singleplayer map, the games checks this byte
7. If it is 1, it will replace the soldier model with a Jawa model which is stored inside the executable

To be honest, I am not entirely sure that its the full model in the executable. I think it is more about the bone information. Though I have no clue why it contains the name of the Jawa model `tat_inf_jawa`.

## Scripts and Cheat Table

I have attached some scripts packed into a cheat table that I found useful while exploring.  
> Please note that these will only work for the 1.2 game version from 2005 and not for the Steam version.

- Disable profile integrity check (the game will also fix the profile with any valid modification)
- Enable easter egg for any profile
  - flag address

## Conclusion

In conclusion, it was a little surprising to me that the reversed FNV-1a algorithm actually worked as expected 😁. The process was pretty challenging for me as it was my first time trying something like this.

Overall, this project was not only enjoyable but I learned a lot, too.  
I'm also super happy I was able to successfully lift the mystery surrounding that easter egg! Although I wish I had some more in depth understanding on the actual activation of the easter egg and where the model information is coming from.

Feedback is always welcome, and I appreciate any corrections or suggestions for improvement. Although I'm not a professional on this topic, I've done my best to present the information accurately and clearly. Thank you for reading!

## Resources

- [Cheat Engine](https://www.cheatengine.org/)
- [HxD Hex Editor](https://mh-nexus.de/en/hxd/)
- [x86 Assembly Guide](https://www.cs.yale.edu/flint/cs421/papers/x86-asm/asm.html)
- [My StackOverflow question](https://stackoverflow.com/questions/62778926/third-operand-of-imul-instruction-is-a-memory-address-what-was-its-original-val)

## Thanks

- Pandemic for SWBF
- DarkByte for Cheat Engine
- CherryDT for answering my StackOverflow question
- Psych0fred for his invaluable contributions to the modding community
- [Jeremy](https://github.com/celltec/)
