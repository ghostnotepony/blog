---
title: "Brief thoughts on CMR vs. SMR in ZFS"
date: 2021-04-24T20:30:00-05:00
---

## Well..I got lucky..

As the title says, I did indeed get lucky recently as I happened to get a very timely reminder (as the return window for the drive was about to close..) about CMR and SMR drives. I had learned a while back that the latter is quite nonperformant and potentially unreliable when used in ZFS, as [these benchmarks demonstrate](https://www.servethehome.com/wd-red-smr-vs-cmr-tested-avoid-red-smr/).  I honestly had not thought of that factor when researching drives for my new ZFS mirror, though.  Unfortunately, the drive I had gotten (and was planning to buy another one of shortly) was on [this list](https://www.truenas.com/community/resources/list-of-known-smr-drives.141/).  Instead, I got 2 CMR drives along with a SATA PCI-Express card.  When all of that arrived, I installed the card and the new drives.  (I also needed to use a power cable splitter to get enough SATA power connectors..at this point, the system had 5 drives in it).  This allowed me to use [zpool replace](https://docs.oracle.com/cd/E19253-01/819-5461/gbcet/index.html) to transparently move the entire mirrored pool to the new drives..the whole procedure took about 3 hours, which was quite a bit less than I had been expecting.

I then removed the drives and prepared the SMR drive for return/refund.  The other drive from the old mirror can finally take a rest after years of reliable service..and watching newer drives come and go.  The first minor issue I ran into was when I started the system up with the new drives..one of them didn't show up.  I switched around SATA cables and ports and such..still not there.  Eventually, I figured out that I couldn't use the same SATA power cable that I had been using with the two old drives and the boot drive as the new ones draw more power (7200 RPM vs. 5400)..so I gave the drive a dedicated cable and it came up.  However, something wasn't quite right:

```
 state: ONLINE
status: One or more devices has experienced an unrecoverable error.  An
        attempt was made to correct the error.  Applications are unaffected.
action: Determine if the device needs to be replaced, and clear the errors
        using 'zpool clear' or replace the device with 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-9P
  scan: resilvered 9.44M in 00:00:01 with 0 errors on Mon Apr 19 16:28:19 2021
config:

        NAME                                 STATE     READ WRITE CKSUM
        tank                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            ata-drive0                       ONLINE       0     0     2
            ata-drive1                       ONLINE       0     0     0

errors: No known data errors
```

I'm still not quite sure how this happened (did trying to use the drive with insufficient power cause this slight data corruption?) but it turned out alright as I just had to clear the error and then scrub the pool to verify all of the checksums.  To clarify, there were two instances where ZFS attempted to read from drive0, but the checksum was not what it expected it to be.  It was able to automatically correct it using the corresponding data from drive1, though, so it worked exactly as it was designed to do.

The scrub itself was much faster than on the old pool; about 1:10 vs. 3:25.  This is due to both drives running at 7200 and using SATA 6Gb ports (not only were the other drives 5400, it was bottlenecking on a SATA 3Gb)..those factors can make a significant difference.  After the scrub, all was well and has been ever since:

```
 state: ONLINE
  scan: scrub repaired 0B in 01:09:56 with 0 errors on Mon Apr 19 17:40:03 2021
config:

        NAME                                 STATE     READ WRITE CKSUM
        tank                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            ata-drive0                       ONLINE       0     0     0
            ata-drive1                       ONLINE       0     0     0

errors: No known data errors
```

The drives are a bit louder than I expected, though I'm used to 5400s, I suppose..at least I know they're doing something. ^^

The lesson I took from this experience is to know exactly what kind of
equipment you're getting and make sure that it suits the purpose that you're
using it for.  SMR drives do have their uses (long term/cold storage and
archiving in general), but are not to be used with ZFS.
