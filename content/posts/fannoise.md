---
title: "Brief thoughts on recent fan noise issues"
date: 2021-05-30T01:35:00-05:00
---

## Silent Lucidity..?

As I mentioned in [a recent blog post](https://ghostnotepony.github.io/posts/newtech/), an issue that I had with my new workstation was that it was making a lot of excessive noise whenever the slightest load would be put on the processor.  I mentioned the [Dark Rock Slim](https://www.bequiet.com/en/cpucooler/1659) in the post and that's what I ended up installing.  That install was quite educational and went really well..just took a long time; it involved removing every cable that was plugged in and removing the motherboard itself from the case.  Then, I had to remove the [stock Wraith Prism cooler](https://www.amd.com/en/technologies/cpu-cooler-solution) and its bracket before installing the bracket and cooler for the Dark Rock Slim (along with removing and re-applying thermal paste..)  After reassembling everything, I was surprised that everything worked the first time I booted it.

Here's data I collected on before and after installing the DRS:
(All data is approximate, of course)

Wraith Prism:
| cpu idle % | cpu temp (C) | fan speed (front) | decibel level | situation           |
| ---------- | ------------ | ----------------- | ------------- | ------------------- |
| n/a        | 33           | 836               | 46            | BIOS screen (cold)  |
| n/a        | 40           | 929               | 52            | BIOS screen (warmed up) |
| 99         | 35.5         | 931               | 44            | idle (cold) |
| 99         | 41.2         | 974               | 50            | idle (warmed up) |
| 96         | 50           | 1196              | 54            | zfs backup |
| 94         | 48.2         | 1061              | 56            | playing Bloodstained: Ritual of the Night |
| 80         | 62           | 1400              | 62            | playing Okami HD |
| 75         | 63.6         | 1394              | 59            | Running Stockfish (chess engine), 4 threads |
| 0          | 77           | 1397              | 62            | Running Stockfish, 16 threads |

Dark Rock Slim:
| cpu idle % | cpu temp (C) | fan speed (front) | decibel level | situation           |
| ---------- | ------------ | ----------------- | ------------- | ------------------- |
| n/a        | 33           | 880               | 40            | BIOS screen (cold)  |
| 99         | 31.6         | 904               | 41            | idle (cold) |
| 99         | 32.5         | 924               | 39            | idle (warmed up) |
| 94         | 55           | 1283              | 42            | zfs backup |
| 95         | 50.2         | 1102              | 41            | light use |
| 94         | 48           | 1049              | 42            | playing Bloodstained: Ritual of the Night |
| 80         | 61           | 1424              | 45            | playing Okami HD |
| 75         | 61           | 1388              | 45            | Running Stockfish, 4 threads |
| 0          | 74.4         | 1400              | 44            | Running Stockfish, 16 threads |

Quite the significant difference..especially considering the difference in noise level between 62 and 44 decibels; it's 7.943 times as loud.

## Stumbling Upon the Answer (again)

I thought this was the end of it, but there was still fan noise whenever the CPU temperature went above 50 or so.  Thus, last night, I decided to try to figure out exactly what was going on..for some reason, heh.  I tested the fans I had installed along with the one on the DRS, but it wasn't any of them.  After trying the front fans that came with the case, though, I found that it was 2 of the 3.  Below a certain RPM threshold, they sound fine; the decibel level at mostly idle is 40-41 dB.

The fix that I figured out/stumbled upon was to go into the BIOS and change the fan curve for these two fans only.  What I came up with was to run these fans at <1000 RPM unless the temperature goes to 70C (I don't have any games right now that can get that high..using [Stockfish](https://stockfishchess.org/) to peg at least 12 of the 16 threads is the only way I've gotten this computer to get that high of a temp.)

So now, running [Okami](https://store.steampowered.com/app/587620/OKAMI_HD/) is 40-41 dB and the CPU doesn't get any hotter than the 61-62 that I recorded in the tables above.  Since decibels are a logarithmic scale, reducing the noise when playing Okami from 62 to 40 dB is a factor of 12.589.   I can also run the 4 thread Stockfish test and it doesn't get any louder as that uses a similar amount of CPU as Okami.

## The Question at..Hoof?

Things seem to be fixed now..but the fact that two of the fans on this are (somewhat) defective makes me wonder how long they'll last..and if I should replace these now instead of later.  When I thought about it, though, so long as the CPU is staying cool enough when being utilized (I may be wrong, but the fact that it doesn't get hotter than 80C at 0% CPU idle means to me that no game or other software can go past that..though, if a game really pushed the graphics card, that might create enough heat to push the CPU over the edge..and also create additional noise when the graphic card fans spin up.  Since I only run at 1080p, though, I have no idea if that's even possible..)

Anyway.

I think I should let it alone for now..(much as I want to attach another fan to the DRS for even more CPU cooling)..but it is a gift to know..when to stop.
