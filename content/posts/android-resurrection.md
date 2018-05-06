---
title: "HTC One A9 Resurrection"
date: 2018-05-05T00:00:00+01:00
tags: [tech, android]
---

**Note: This worked for me.  It may not work for you.  YMMV.**

# A brick in the hand is worth... nothing?
For the past year or so, I've had an [HTC One A9](https://www.gsmarena.com/htc_one_a9-7576.php) lying in my drawer.  A previous attempt to install a custom ROM on it had left it in a sorry state. When I turned it on it would just stay stuck at the green and white boot screen with the scary red legal disclaimer from HTC.  When I tried powering it off again, it would just turn on again and get stuck in the exact same place. I believe 'well and truly bricked' may be the term here.

Thankfully today, after some fiddling around I was able to successfully un-brick it and get it up and running again.  The short version is that I re-installed a stock ROM on the phone, and it then booted up again.  It sounds simple, but it wasn't (at least for me).

# Prerequisites
I had already [unlocked the phone's bootloader](https://www.htcdev.com/bootloader/), installed [ClockWorkMod Recovery](https://forum.xda-developers.com/wiki/ClockworkMod_Recovery), and [rooted it](https://theunlockr.com/2016/03/22/root-htc-one-a9/).  If you haven't done this, it's unlikely that you would have gotten yourself into this mess in the first place.  If, somehow, you have no custom recovery or no ability to transfer files to the device, you have yet another hole to dig yourself out of first.

It goes without saying that you will need `adb` and [`htc_fastboot`](https://www.htcdev.com/process/legal_fastboot_linux) installed on your computer, and a USB cable to connect the device.  You will then also want to take note of your original output of `htc_fastboot getvar all` when your device is in download mode.

It also goes without saying that you should really back up any data on the device you care about.

# Taking Stock (of ROMs, that is)
There is a [fantastic thread on xda-developers](https://forum.xda-developers.com/one-a9/general/wip-ruu-htc-one-a9-t3240344) boasting a dizzying list of Stock HTC ROMs of various versions.  It took me some trial and error before I found one that worked.

The three things I needed to worry about were:
a) Your device model (mine is `hiaeuhl` a.k.a. `HIA_AERO_UHL`)
b) Your `version-main` (a.bb.ccc.dd)
c) Your CID (Carrier ID e.g. `H3G__003`)

If you have an unlocked bootloader and you do not have `S-OFF` then you are unable to change your CID.  You will be unable to install any stock ROMs that do not have your device's CID listed.

Once you find one or more ROMs that correspond to both your device model and your CID, find the one with the `version-main` closest to your device.  Read the section [RUU version numbers explained](https://forum.xda-developers.com/showpost.php?p=63640734&postcount=2) in the FAQ post of the super-thread. The important numbers are `aa` and `bb`; `ccc` and `dd` are less important and you _should_ be fine with installing a ROM for a different minor patch level and/or carrier.

When you find the correct one, installing it is rather simple: copy it to the device (e.g. via `adb push`) and ensure it is accessible under the path  `/external_sd/2PQ9IMG.zip`.  When your device enters download mode (`Power+VolDown` on boot) it will automatically prompt you to install it, if found.

# ROM-Comedies
My big problem was that the only ROM matching my device and CID had a different `version-main` than that of my phone.  When I tried flashing one of these ROMs, I got an error `19 RU_MAIN_VER_FAIL os-version in android-info missing or incorrect`.  I then tried separately with a different ROM that had the correct `version-main` but a different CID.  This also failed with a different error message `RU_CID_FAIL cid in android-info`. 

At this point it seemed impossible to make any progress, until I re-read the [FAQ post](https://forum.xda-developers.com/showpost.php?p=63640734&postcount=2) of the XDA-Developers GigaThread - specifically, part 6 "DOWNGRADING WITH S-ON". 

# Hex; Or Dumping in the Infernal Method
So, it turns out that you can fake your `version-main` with the aid of good old `dd` and `hexdump`.  The trick here is to pick a ROM close enough to your existing version-main with the matching CID so that in the worst case, what you are installing is only a couple of minor patch levels away from your device's firmware.  Don't bother trying this to change your CID, it doesn't work.

My approach was to `adb shell`, `dd if=/dev/block/mmcblk0p28 of=/external_sd/misc.dd`, and then `adb pull` it over to my computer and use a hex editor to edit the correct offsets.  I was on a Windows machine at the time, so I used [HxD](https://mh-nexus.de/en/hxd/).  

After editing the dump on my computer (and making a backup of the original), I `adb push`-ed it back to the device, opened `adb shell` once more and ran the inverse of the original `dd` commands (`dd if=/external_sd/modified_misc.dd of=/dev/block/mmcblk0p28`).  One `adb reboot recovery` later, the correct `version-main` for the stock ROM I wanted to install was showing up.

I was then able to successfully flash the stock ROM, which un-bricked the phone! 