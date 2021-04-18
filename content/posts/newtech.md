---
title: "Thoughts on my new workstation/server conversion"
date: 2021-04-17T22:00:00-05:00
---

## Introduction

Well, it's been quite a while since I wrote anything on this site..and quite a lot has happened in the world (massive understatement, I know) and in my own life.  I've talked about those things (mostly) as they happened on my Twitter, so if you are curious as to what I am referring to, [head over there](https://twitter.com/ghostnotepony) and have a look.  (In summary, I discovered my bisexuality/queerness, I've gotten a lot of pony art commissioned/embraced wanting to be an adorable little unicorn, I've struggled immensely with anxiety but have made tremendous progress, especially lately..and I'm a lot happier of an individual lately, overall.)

This post, though, is about my new workstation and how I converted my previous one (which I had used for 10+ years) into a server.  Instead of a strictly chronological account, I'm going to go over the various obstacles I faced, how I solved/worked around them, and the current minor issues I'm seeing.

## Workstation build/thoughts

[These are the specs I decided on after a lot of research and thought.](https://pcpartpicker.com/list/TCyvcT)  Due to the inequitable and unjustifiable scarcity of video cards, I moved my existing one into the new computer; I had found a 20+ year old Voodoo3 card that would be put into the server as all it needs after the installation are text consoles..this card, with its "sizable" 16M of video memory, doesn't even need a fan and thus draws a lot less power than this Radeon RX580 behemoth.  (More on how that worked out during the install later..)

The first obstacle I ran into was attaching the power supply..I couldn't get it screwed in properly and I was getting frustrated over it (though nothing like the issues I had 10 years ago..and now I know why which I'll explain in the server section.)  So I eventually had my wife look at it and she noticed I was using the wrong screws.  (I love her so much ^^)  The lessons to be learned from this case are that it never hurts to have another set of eyes check your work..and make sure you're using the proper screws. ^^

After that, the build proceeded smoothly until it came time to install the M2 NVMe SSD.  I had never done this before, and so I just did what I thought was the proper procedure.  After installing the video card, I hooked the workstation up and hoped it would pass the first POST..and it did.  However, the NVMe wasn't showing up..and every time I worked on it I had to remove the video card as well.  Eventually, I figured out that I should read the instructions, heh.  My problem was that I was attaching the NVMe with the heatsink and not screwing it to the motherboard.  The proper procedure is to first insert it at an angle, gently press it down and then screw it into the motherboard standoff.  I had issues with that due to how tiny the screw is but I eventually got it in.  *Then* the heatsink can be put on. ^^  Now that the NVMe was present, I could install [Arch](https://archlinux.org) on it and copy over my files; all of that went smoothly.

I was also happy that [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) worked right away, though I'm still figuring out how to use it more effectively.  The CLI can be used in scripts as well, though I'm a bit disappointed that the front fans can't have their colors changed individually..I wanted them to show the bi colors ^^  Otherwise, this system is so much faster than the old and I'm still marveling over how I can have the same programs open but use about 15-20% of memory instead of 70-80 (the difference between 12 and 32..and also moving up to DDR4-3200 speed-wise.)  I tried out everything in my very small Steam library and the most taxing game was [Okami HD](https://store.steampowered.com/app/587620/Okami_HD/), which got the processor to 25% usage overall.

Something I need to rectify is the number of fans in this system..I just have the stock front 3 running and, as a result, it gets louder than I'm accustomed to when playing a game/taxing the CPU at all.  My previous box had front, overhead, and back fans which helped that issue, to my knowledge.  Of course, this case has room for a lot more fans..and potentially more color combinations. ^^

A couple of software issues I had were that suspending the system didn't work (it would just turn back on) and that WOL (Wake on LAN) wasn't doing anything.  To fix the latter, I had to configure the interface to utilize that functionality (much as I did with the previous one, though I forgot about it..fortunately, I had the old /etc directory handy ^^)  To fix the suspension issue, I eventually figured out I had to change /proc/acpi/wakeup and disable everything there or those components would keep instantly waking the system up.  So I wrote a suspend script to handle that:

```
#!/bin/sh

if [ $UID != 0 ]; then
        echo "Run with sudo"
        exit 255
fi

for i in $(grep pci /proc/acpi/wakeup | cut -d ' ' -f1)
do
	echo $i > /proc/acpi/wakeup
done

# Just to verify it
cat /proc/acpi/wakeup
# Give yourself time to ctrl-c out if something goes wrong...
sleep 5

systemctl suspend
```

And it works just fine..most of the time ^^

Another minor issue that I hoped moving to a new system/distro would fix was that the monitor does not go into suspend mode when the system is locked..instead, it shows a black screen while staying on.  Until I looked into it some more, I thought it was a problem with my monitor..instead, it's a [known bug](https://bugzilla.redhat.com/show_bug.cgi?id=1894624).  Whether I'm in X.org or Wayland, the issue occurs.  From what I read, using a DisplayPort monitor might fix it but that's an expensive solution to a very minor issue.  (An DP -> HDMI cable seems like a much cheaper alternative, but that won't work either, bah.)

However, running this command in a loop *does* suspend the monitor properly:
```
$ busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 3
```

I was glad to see this, even though it's not a viable workaround as there's no way to interrupt it aside from using another device to ssh in and kill the process..that's too much work for something like this.  Yet, it demonstrates that this is a software issue and can be fixed..perhaps in the next major release of GNOME.

The other thing I've tweaked lately is changing the fan speed curve to not be so aggressive..as I talked about above, it was causing lots of noise/sudden fan speed-ups for the slightest bit of CPU usage.  I am considering getting an aftermarket cooler [like this one](https://www.bequiet.com/en/cpucooler/1659) but first I'm going to max out the fans in the case to see if that helps noise/CPU temperature.  (Edit: it has helped so far, thankfully.)

Otherwise..I'm very, very happy with my new workstation ^^

## Server build/thoughts

As for my former workstation, converting it into a RHEL/RHEL-like server..was harder.  

First, it wasn't booting with an 8G USB drive but it did with a 4..I didn't think much of this at the time, but it was an important clue.   Next was the fact that I couldn't do a text install with RHEL as it wouldn't let me point to their CDN.  "Okay," I thought, "Even this old graphics card should work for the graphical install, right?"  Wrong.  The image on the screen was extended/distorted and I couldn't use it at all, even when trying it with 2 different monitors.  Then, I started thinking.."Well, if I need to kickstart it, that's fine.." so I started looking around the installation docs for information on that..and then I stumbled upon the [VNC](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_an_advanced_rhel_installation/performing-a-remote-installation-using-vnc_installing-rhel-as-an-experienced-user) section..which I had never used in all my experience with RHEL.

But in this case, it was exactly the right solution.

After getting the OS installed, I got [ZFS](https://zfsonlinux.org/) setup and the pool imported, as planned.  However, backups to the pool over the network weren't going well either with the AX200 or a USB3 wifi card (which required using an [elrepo](https://elrepo.org) kernel as I couldn't get its driver compiled with the stock RHEL 8 one) but a replacement AX200 with an external antenna worked a lot better and made backups possible. (Later, I was able to boost its signal somewhat with another antenna with longer cables.)  Next (in no particular order), was setting up [nginx](https://nginx.org), a TLS key and cert for it, php, adjusting selinux to work with those, finding a CLI [CD ripper](https://abcde.einval.com/wiki/), getting DNS set up, compiling [makemkv](https://makemkv.com) (hint: use ./configure --without-gui on a headless box)..

The most time-consuming setup was for [Plex](https://plex.tv), though.  Getting it to redirect the way I wanted it to from nginx wasn't going well until I figured out I needed to create a CNAME record for it along with a separate server for it (and cert/key) in nginx.conf.  After doing that, everything was working well and I was able to start ripping CDs (almost) right into it.

Backups were..interesting.  I kept trying to make a combined rescue/backup image but it would not boot no matter what..rather miffed, I started searching around and found the other piece to the puzzle..confirmation that it's impossible to boot this motherboard with a USB drive that's larger than 4G no matter how small the boot image itself is.  (This was what I missing 10 years ago when I tried to install it with an 8G drive and had a very, very frustrating day..)  After poking around the docs, I found that I could separate the rescue image from the backup itself.  So then I got a large USB flash drive dedicated to doing backups and that's how I was able to make daily ones..which proved *very* useful a lot sooner than I thought..

The last few steps were setting up monitoring (other devices and monitoring of the server itself) and email so I could get alerts from it. ([zed](https://utcc.utoronto.ca/~cks/space/blog/linux/ZFSZEDPraise), the ZFS event daemon, can also send mail about anything that happens ZFS-wise, which I only learned about recently.)  Everything seemed fine..until..
## March 20, 2021 - server disaster day

Well, I screwed up..but it was quite the learning experience.  It all started when I got a smartd mail about one of the drives in my ZFS pool on the night of the 19th..so I did a backup and then I figured I'd check it on the 20th. I did so and the drive indeed was on its way out.  I ordered a new drive and then figured that I would need something to convert IDE to SATA power, so I found the right part and tacked it on as well.  Everything was fine at this point..which is when I started making things a lot worse by pushing too hard and not recognizing when it was time to just let it be..something I need to work on, overall.

So the colossal mistake I made was that I spotted a modular power supply cable from my new PS that was unused as there are no SATA devices in this workstation.  So I thought "Might as well try it out on my server boot SSD...different power supplies, yeah, but it's the same manufacturer so it should be fine...."

As soon as I plugged it in and powered on the system, I realized I had made a horrible mistake..there was the unmistakable stench of electronic components burning.

What I think happened (and anyone who knows better can correct me on this) is that, since the new PS is 650W while the old one is 800, the cable could not handle that much power and my boot drive took the brunt of it.  After *very* quickly shutting everything down, disconnecting the drive and taking that cable out ASAP, I tried to see if I could get the drive to come up at all..but troubleshooting revealed that it was simply invisible to the OS.   So..I ordered another SSD and felt very, very thankful that I had gotten a recent backup.  The new HDD for ZFS arrived on the 21st and I was able to use a [ZFS rescue image](https://github.com/leahneukirchen/hrmpf/) to replace the old one with the zpool replace command, which copies everything from the good drive(s) (tmk) to the new one and then removes the old one at the end.  It took 7 1/2 hours, but it was completed without any issues.  On the 22nd, I wiped the old drive using [hdparm](https://grok.lsu.edu/Article.aspx?articleid=16716) and the new SSD arrived unexpectedly early..so it was time to restore the backup (which I had also made another backup of, just to be sure..)

It all went smoothly from there, fortunately..a few odds and ends needed fixing after the restore but after that was taken care of the server was back in business and it didn't have any issues with using the ZFS pool.

(Update..due to [this issue](https://www.reddit.com/r/unRAID/comments/gwighw/solution_to_i_can_not_recommend_crucial_ssds_for/), I returned the SSD and replaced it with a similar-sized one from another manufacturer.  I did a backup just before I switched the drives and the restore worked on the new drive without any issues..kind of crazy that this system is on its third boot drive and I've been able to restore it successfully twice..well, at least I know my restores are working!)

## Since then..

I've installed [owncloud](https://www.owncloud.com) on the server using nginx (aka the hard way..the easy way is Apache, but I'm trying to learn nginx and setting this up was quite the learning experience for it..)  Thus, I had to dig through forum posts, repeatedly try and fail various configurations..until it all came together and, as I put it to my wife, "We now have Dropbox in our basement."  It's worked quite well since then, though I've found that using a [davfs2 mount](https://wiki.archlinux.org/index.php/Davfs2) along with the owncloud desktop client works better for me.  The davfs2 mount is for my media which takes up a lot of space and which I don't need locally synced since I'm already storing it on ZFS, etc.  Setting up the desktop client for documents/much smaller files works well as those are the ones I work on/need quick access to most often.  There is a [virtual file system](https://owncloud.com/virtual-file-system/) option, but when I tried it out, it didn't work for me at all.  Every file became one byte long with an .owncloud extension but I couldn't find a quick way via the command line to download the files I wanted.  Also, browsing images didn't work either..it's probably something that isn't quite Linux-friendly yet.

Overall, owncloud and plex have been fun to play with/use so far and the server itself is going well now.  The last thing left to upgrade is to get another 8T drive and replace the existing 2T one..it will require getting a SATA card so that every drive can use 6G ports (only two on the motherboard), but I have all the other cables necessary.  To conclude, this was a successful endeavor..along with a very educational one.

## Afterword: Moving to Arch

As aforementioned, I installed Arch on the new workstation as I have been using it on an increasing number of my devices..it feels somewhat like a modern [Slackware](http://www.slackware.com) to me (which was my first Linux distro and I ran it until about 2007 or so) in that there are no real defaults and the installation is quite manual.  I switched from Slack to Fedora because I was having to compile so many programs that were not available as packages that I felt like I was running a quasi-Gentoo setup.  One reason for switching from Fedora to Arch is that the same thing was starting to happen..and I was getting slightly irritated that I was getting software/kernels on Arch from several days to a week and a half or so earlier.

Also, I did not approve of Fedora's decision to switch to btrfs as the default file system (as I noted [in this Twitter thread](https://twitter.com/ghostnotepony/status/1298699445375205376)).  I still don't like it and I'm confused about the direction that Fedora is going in, especially given the decision to [kill CentOS](https://arstechnica.com/gadgets/2020/12/centos-shifts-from-red-hat-unbranded-to-red-hat-beta/) (which also killed a *lot* of trust for Red Hat across computing in general).  If Canonical can have [ZFS as part of Ubuntu](https://ubuntu.com/blog/zfs-licensing-and-linux) and not face any consequences from Oracle, why can't Red Hat put it in Fedora?  Of course, they would have to leave it out of RHEL completely, as Oracle likely *would* sue over that but as for Fedora..hmm, well, it is a big gray area, overall, to be fair.  (Why Oracle doesn't leverage ZFS for its RHEL-compatible distro, though..I have no idea; who's going to sue *them*?)  The FSF certainly isn't going to do anything about it.  Along with being a cult of personality, it is quite irrelevant to most of the Linux community (and computing in general) and has been for an extended period.

All that aside, Arch works quite well for me and I've found that the rolling release schedule fits a workstation/personal laptop a lot better than Fedora's path of upgrading every 6-12 months.  (Server distribution releases, though, are slow and consistent by design..I'm glad I don't have to constantly update my server and it'll receive at least minor updates until 2029..or longer if I can upgrade to the next major release.)  I will compliment Fedora on making system upgrades simple and straightforward; for several years, I never had to reinstall the OS to migrate.

Overall, I think Fedora is still a good distribution and is always a good indicator of where RHEL is headed next, but it's not the right one for me at this moment.

## Appendix: owncloud (in the web root) nginx configuration
```
   server { 
      listen 443 ssl http2;
      include /etc/nginx/default.d/*.conf;
      server_name server.fqdn.org;
      ssl_certificate /etc/nginx/certs/owncloud.crt;
      ssl_certificate_key /etc/nginx/certs/owncloud.key;
      ssl_prefer_server_ciphers on;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers EECDH+AESGCM:EDH+AESGCM; 
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

      # Additional config below derived from https://doc.owncloud.org/server/8.0/admin_manual/installation/nginx_configuration.html
      # https://central.owncloud.org/t/nginx-documentation-unofficial-community/22365/2 is also helpful

      # Path to the root of your installation
      root /path/to/root;
      location = /robots.txt {
         allow all;
         log_not_found off;
         access_log off;
      }

      location = /.well-known/carddav {
         return 301 $scheme://$host:$server_port/remote.php/dav;
      }
      location = /.well-known/caldav {
         return 301 $scheme://$host:$server_port/remote.php/dav;
      }

      # set max upload size
      client_max_body_size 512M;
      fastcgi_buffers 8 4K;
      fastcgi_ignore_headers X-Accel-Buffering;

      # Disable gzip to avoid the removal of the ETag header
      # Enabling gzip would also make your server vulnerable to BREACH
      # if no additional measures are done. See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=773332
      gzip off;

      # Uncomment if your server is built with the ngx_pagespeed module
      # This module is currently not supported.
      #pagespeed off;

      error_page 403 /core/templates/403.php;
      error_page 404 /core/templates/404.php;

      location / {
         rewrite ^ /index.php$uri;
      }

      location ~ ^/(?:build|tests|config|lib|3rdparty|templates|changelog|data)/ {
         return 404;
      }
      location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console|core/skeleton/) {
         return 404;
      }
      location ~ ^/core/signature\.json {
         return 404;
      }

      location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|oc[sm]-provider/.+|core/templates/40[34])\.php(?:$|/) {
         fastcgi_split_path_info ^(.+\.php)(/.*)$;
         include fastcgi_params;
         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
         fastcgi_param SCRIPT_NAME $fastcgi_script_name;
         fastcgi_param PATH_INFO $fastcgi_path_info;
         fastcgi_param HTTPS on;
         fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
         fastcgi_param front_controller_active true;
         fastcgi_read_timeout 180; # increase default timeout e.g. for long running carddav/caldav syncs with 1000+ entries
         fastcgi_pass php-fpm;
         fastcgi_intercept_errors on;
         fastcgi_request_buffering off; #Available since Nginx 1.7.11
      }

      location ~ ^/(?:updater|oc[sm]-provider)(?:$|/) {
         try_files $uri $uri/ =404;
         index index.php;
      }

      # Adding the cache control header for js and css files
      # Make sure it is BELOW the PHP block
      location ~ \.(?:css|js)$ {
         try_files $uri /index.php$uri$is_args$args;
         add_header Cache-Control "max-age=15778463" always;

         # Add headers to serve security related headers (It is intended to have those duplicated to the ones above)
         # The always parameter ensures that the header is set for all responses, including internally generated error responses.
         # Before enabling Strict-Transport-Security headers please read into this topic first.
         # https://www.nginx.com/blog/http-strict-transport-security-hsts-and-nginx/

         #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;
         add_header X-Content-Type-Options "nosniff" always;
         add_header X-Frame-Options "SAMEORIGIN" always;
         add_header X-XSS-Protection "1; mode=block" always;
         add_header X-Robots-Tag "none" always;
         add_header X-Download-Options "noopen" always;
         add_header X-Permitted-Cross-Domain-Policies "none" always;
         # Optional: Don't log access to assets
         access_log off;
      }

      location ~ \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg|map|json)$ {
         add_header Cache-Control "public, max-age=7200" always;
         try_files $uri /index.php$uri$is_args$args;
         # Optional: Don't log access to other assets
         access_log off;
      }
   }
```
