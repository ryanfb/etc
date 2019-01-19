---
title: Raspberry Pi 2 Game Emulation Roundup 2016
affiliate: true
---

Over the holidays, I got a Raspberry Pi 2 in order to experiment with various projects. One thing I was interested in was seeing how it would work for classic game console emulation, since the 900MHz ARMv7 should be enough to handle most of the older consoles pretty well, and the form factor of a small fanless box which can connect via HDMI and use an existing (e.g. DualShock 3) wireless controller seemed ideal.

I used the following hardware to get up and running:

* [CanaKit Raspberry Pi 2 Starter Kit](http://amzn.to/1UrzRVa) ($69.99) - includes the Raspberry Pi 2, USB WiFi adapter, 8GB microSD, power supply, and a nice case
* [Plugable USB BLuetooth 4.0 Adapter](http://amzn.to/1Z3zy9A) ($13.95) - to be able to use my existing controllers wirelessly
* USB keyboard from the back of my closet. You _may_ need one of these to do the initial setup for some of these packages after booting, especially if you want to use a WiFi-only network and Bluetooth. Something like [this](http://amzn.to/1Z3BwqL) will probably do the job if you don't have a USB keyboard kicking around somewhere.

With that, setup was pretty easy.[^noobs] For most packages, you just download and image the SD card from a computer then put it in the RPi2 and boot up. Here's all the existing all-in-one emulation frontend packages I was able to find for the Raspberry Pi 2, collected in one place:

[^noobs]: I initially tried using the preloaded NOOBS bootloader/installer that came on the CanaKit microSD card, but accidentally installed an RPi1 version of Lakka which wouldn't boot, and then apparently messed things up more trying to fix it. I found just wiping and imaging the microSD card each time was easier.

## [Lakka](http://www.lakka.tv/)

* [Video](https://www.youtube.com/watch?v=JwUVV3xMRwU)
* [Install instructions](http://www.lakka.tv/get/)
* Frontend: [RetroArch](https://github.com/libretro/RetroArch)
* Backend: [libretro](http://www.libretro.com/)
* OS: [OpenELEC](http://openelec.tv/)
* [Supported](https://github.com/libretro/Lakka/wiki/Hardware-support#which-systems-are-supported): 2048, Atari 2600, Atari Lynx, Cave Story, Dinothawr, Doom, FB Alpha, Game Boy, Game Boy Advance, Game Boy Color, Game Gear, Master System, Mega Drive, NES, Neo Geo Pocket, Nintendo 64, PCEngine, PCEngine CD, PlayStation, Sega 32X, SuperNES, Vectrex

## [Recalbox](http://www.recalbox.com/)

* [Video](https://www.youtube.com/watch?v=t7i-G_4lRWQ)
* [Install instructions](http://www.recalbox.com/diyrecalbox)
* Frontend: [Forked EmulationStation](https://github.com/recalbox/recalbox-emulationstation)
* Backend: [libretro](http://www.libretro.com/)
* OS: [Custom buildroot Linux](https://github.com/recalbox/recalbox-buildroot)
* [Supported](https://github.com/recalbox/recalbox-os/wiki/Home-%28EN%29): Atari 2600, Atari 7800, NES, Game Boy, Game Boy color, Game Boy Advance, Super Nintendo, Famicom Disk System, Master System, Megadrive (Genesis), Gamegear, Game and Watch, Lynx, NeoGeo, NeoGeo Pocket, FBA (subset), iMame4all (subset), PCEngine, Supergrafx, MSX1/2, PSX, Sega Cd, Sega 32X, Sega SG1000, Playstation, ScummVM, Vectrex, VirtualBoy, Wonderswan

## [RetroPie](http://blog.petrockblock.com/retropie/)

* [Video](https://www.youtube.com/watch?v=vfFd-CsbnY8)
* [Install instructions](https://github.com/RetroPie/RetroPie-Setup/wiki/First-Installation)
* Frontend: [EmulationStation](https://github.com/Aloshi/EmulationStation)
* Backend: [libretro](http://www.libretro.com/)
* OS: [Raspbian](https://www.raspbian.org/)
* [Supported](https://github.com/RetroPie/RetroPie-Setup/wiki/Supported-Systems-Emulators): Amiga (UAE4All), Apple II (Basilisk II), Arcade (PiFBA), Atari 800, Atari 2600 (RetroArch), Atari ST/STE/TT/Falcon, C64 (VICE), CaveStory (NXEngine), Doom (RetroArch), Duke Nukem 3D, Final Burn Alpha (RetroArch), Game Boy Advance (gpSP), Game Boy Color (RetroArch), Game Gear (Osmose), Intellivision (RetroArch), MAME (RetroArch), MAME (AdvMAME), NeoGeo (GnGeo), NeoGeo (Genesis-GX, RetroArch), Sega Master System (Osmose), Sega Megadrive (DGEN, Picodrive), Nintendo Entertainment System (RetroArch), N64 (Mupen64Plus-RPi), PC Engine / Turbo Grafx 16 (RetroArch), Playstation 1 (RetroArch), ScummVM, Super Nintendo Entertainment System (RetroArch, PiSNES, SNES-Rpi), Sinclair ZX Spectrum (Fuse), PC / x86 (rpix86), Z Machine emulator (Frotz)
 
## [PiPlay](http://piplay.org) (formerly PiMAME)

* [Video](https://www.youtube.com/watch?v=IBubgnwDqdY)
* [Install instructions](https://gist.github.com/igorissen/2ba54c7c82d9355f74ca)
* Frontend: custom
* Backend: various
* OS: [Raspbian](https://www.raspbian.org/)
* [Supported](http://piplay.org/): MAME (AdvanceMAME & MAME4ALL), CPS I / CPS II (Final Burn Alpha), Neo Geo (GNGeo), Playstation (pcsx-reARMed), Genesis (DGen), SNES (SNES9x), NES (AdvMESS), Gameboy (Gearboy), Gameboy Advance (GPSP), ScummVM, Atari 2600 (Stella), Cavestory (NXEngine), Commodore 64 (VICE)

## [ignition.io](http://ignition.io/)

* Forthcoming
* [Video](https://ksr-video.imgix.net/projects/960149/video-416728-h264_high.mp4)
* Frontend: custom
* Backend: [libretro](http://www.libretro.com/) / various
* OS: ???

### Footnotes
