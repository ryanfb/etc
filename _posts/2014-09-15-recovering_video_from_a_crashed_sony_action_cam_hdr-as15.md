---
title: Recovering video from a crashed Sony Action Cam HDR-AS15
---

**Update**: A correspondent writes that for a different truncated MP4 they were trying to recover, the `untrunc` instructions below were unsuccessful but that `recover_mp4` was able to give them good results, using [this guide](https://tehnoblog.org/video-repair-guide-corrupted-mp4-avi-h264-file-fix/).

A couple days ago, my Sony Action Cam popped off my bike when I went over a bump near the bottom of a hill, where it was promptly run over by several cars. Amazingly, it still seems to function fine. I wanted to check out the video to see if any of the tumbling and running over got captured, and thought the methods I used might be helpful to anyone who finds themselves in a similar situation. As long as the microSD card is intact, you might have a good chance of recovering something.

First, I copied the latest two MP4 video files off the card out of the `MP_ROOT/100ANV01` onto my local drive so I wouldn't worry about screwing them up. Then, I tried various players/encoders (Quicktime, VLC, mplayer, ffmpeg, mencoder) to see if I could trivially recover anything from the latest file. No dice. It seemed corrupt, but there was definitely 600MB of data there, which is about the size it should be for the length of time it was recording. Some googling turned up the excellent [untrunc](https://github.com/ponchio/untrunc) software which I was able to compile[^1] with [this patch applied](https://gist.githubusercontent.com/ryanfb/ad6dada779c5745e1e22/raw/3e20f3c17648815ae348980b8e2487a12478dca9/untrunc.patch). Running it against the unmodified video files I had, it gave the following error:

    $ ./untrunc/untrunc MAH00093.MP4 MAH00094.MP4                  [18:38:51]
    Reading: MAH00093.MP4
    Composition time offset atom found. Out of order samples possible.
    Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'MAH00093.MP4':
      Metadata:
        major_brand     : MSNV
        minor_version   : 22675568
        compatible_brands: MSNVmp42isom
        creation_time   : 2014-09-10 13:51:22
      Duration: 00:10:40.64, start: 0.000000, bitrate: 16113 kb/s
        Stream #0:0(und): Video: h264 (Main) (avc1 / 0x31637661), yuv420p, 1920x1080 [SAR 1:1 DAR 16:9], 15982 kb/s, 29.97 fps, 29.97 tbr, 30k tbn, 59.94 tbc (default)
        Metadata:
          creation_time   : 2014-09-10 13:51:22
          handler_name    : Video Media Handler
          encoder         : AVC Coding
        Stream #0:1(und): Audio: aac (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 127 kb/s (default)
        Metadata:
          creation_time   : 2014-09-10 13:51:22
          handler_name    : Sound Media Handler
    Failed to parse atoms in truncated file

`Failed to parse atoms in truncated file` was similar to what I got trying to extract a transport stream with ffmpeg:

    $ ffmpeg -i MAH00094.MP4 -c copy -bsf:v h264_mp4toannexb -f mpegts MAH00094.ts  
    ffmpeg version 2.3.3 Copyright (c) 2000-2014 the FFmpeg developers
      built on Aug 25 2014 19:47:15 with Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)
      configuration: --prefix=/usr/local/Cellar/ffmpeg/2.3.3 --enable-shared --enable-pthreads --enable-gpl --enable-version3 --enable-nonfree --enable-hardcoded-tables --enable-avresample --enable-vda --cc=clang --host-cflags= --host-ldflags=     --enable-libx264 --enable-libfaac --enable-libmp3lame --enable-libxvid
      libavutil      52. 92.100 / 52. 92.100
      libavcodec     55. 69.100 / 55. 69.100
      libavformat    55. 48.100 / 55. 48.100
      libavdevice    55. 13.102 / 55. 13.102
      libavfilter     4. 11.100 /  4. 11.100
      libavresample   1.  3.  0 /  1.  3.  0
      libswscale      2.  6.100 /  2.  6.100
      libswresample   0. 19.100 /  0. 19.100
      libpostproc    52.  3.100 / 52.  3.100
    [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7fdd63021800] Format mov,mp4,m4a,3gp,3g2,mj2 detected only with low score of 1, misdetection possible!
    [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7fdd63021800] moov atom not found
    MAH00094.MP4: Invalid data found when processing input

Looking at my two files with the `xxd` hex dumper made me think that maybe the Action Cam writes a placeholder header which it leaves there until it finishes a recording, when it replaces it with the real header:

    $ xxd MAH00093.MP4|head -20                                    [12:11:21]
    0000000: 0000 001c 6674 7970 4d53 4e56 015a 0070  ....ftypMSNV.Z.p
    0000010: 4d53 4e56 6d70 3432 6973 6f6d 0000 0094  MSNVmp42isom....
    0000020: 7575 6964 5052 4f46 21d2 4fce bb88 695c  uuidPROF!.O...i\
    0000030: fac9 c740 0000 0000 0000 0003 0000 0014  ...@............
    0000040: 4650 5246 0000 0000 0000 0000 0000 0000  FPRF............
    0000050: 0000 002c 4150 5246 0000 0000 0000 0002  ...,APRF........
    0000060: 6d70 3461 0000 0229 0000 0000 0000 0080  mp4a...)........
    0000070: 0000 0080 0000 bb80 0000 0002 0000 0034  ...............4
    0000080: 5650 5246 0000 0000 0000 0001 6176 6331  VPRF........avc1
    0000090: 014d 0028 0002 0002 0000 3e80 0000 3e80  .M.(......>...>.
    00000a0: 001d f853 001d f853 0780 0438 0001 0001  ...S...S...8....
    00000b0: 4ce6 0430 6d64 6174 0000 0002 0910 0000  L..0mdat........
    00000c0: 0013 0600 0d80 afc8 0000 0300 00af c800  ................
    00000d0: 0003 0040 8000 0000 0e06 0109 0000 0824  ...@...........$
    00000e0: 6800 0003 0001 8000 0000 0506 0601 c480  h...............
    00000f0: 0007 6fe6 2588 8406 4555 2a80 e749 81a7  ..o.%...EU*..I..
    0000100: a080 0ff8 efab 530b 1402 1942 4990 98fa  ......S....BI...
    0000110: b632 9102 6b74 7497 10e9 eb6e 2453 e980  .2..ktt....n$S..
    0000120: ae2f 7391 b166 c64d 3d6a 4ae2 c4c1 5a81  ./s..f.M=jJ...Z.
    0000130: 4bb1 2455 2a0c 12a1 62dc e697 cab3 e5c8  K.$U*...b.......
    $ xxd MAH00094.MP4|head -20                                    [12:11:25]
    0000000: fbff ffff ff9f ffff f7ef d3b7 fdff fdff  ................
    0000010: fbff ffd7 fff6 f7f7 ffff 7ff7 ffff f7e7  ................
    0000020: ff6b ffff f7f7 fdff f5ff ffef f7db fef9  .k..............
    0000030: ffdf bfbe ffff ffff ffff e2ff 5fff f7f7  ............_...
    0000040: 7fff f7ff ffaf e7f7 fffb ffff fffb beff  ................
    0000050: ff57 fbbf 5fff feaf feff deff fffa ff9f  .W.._...........
    0000060: f7fd ffff bffb fffe ffff f7ee f7fd febf  ................
    0000070: ffff ffff beef fbff ffff ffff df77 cfbf  .............w..
    0000080: ffff bfff ffff ff4f fffb fbff bffe f7fb  .......O........
    0000090: fafe ffff feff efff 7dbf d6ff f7f7 7fef  ........}.......
    00000a0: feeb ffff fefb ffff ffff feff ffbc fefb  ................
    00000b0: fdf7 fffe c7ff afff 0000 0002 0910 0000  ................
    00000c0: 0013 0600 0d80 afc8 0000 0300 00af c800  ................
    00000d0: 0003 0040 8000 0000 0e06 0109 0000 0824  ...@...........$
    00000e0: 6800 0003 0001 8000 0000 0506 0601 c480  h...............
    00000f0: 0007 390a 2588 8406 454b b57c 50f1 1880  ..9.%...EK.|P...
    0000100: 141b 8c66 f784 77c9 40f2 e916 c558 1d28  ...f..w.@....X.(
    0000110: 1187 f8f9 d0fd b128 1b21 8bc6 44cd 39a3  .......(.!..D.9.
    0000120: 4794 8156 128d 4ce0 8dad e0f5 0210 9d84  G..V..L.........
    0000130: 12fc 9ed4 866e 8736 0444 c9b5 0bc5 4469  .....n.6.D....Di
    
The sequence `0000 0002 0910` seemed to be where the "video" started, so I used [Hex Fiend](http://ridiculousfish.com/hexfiend/) to replace the corrupted header and save a new file:
    
    $ xxd MAH00094-header.MP4|head -20                             [12:13:56]
    0000000: 0000 001c 6674 7970 4d53 4e56 015a 0070  ....ftypMSNV.Z.p
    0000010: 4d53 4e56 6d70 3432 6973 6f6d 0000 0094  MSNVmp42isom....
    0000020: 7575 6964 5052 4f46 21d2 4fce bb88 695c  uuidPROF!.O...i\
    0000030: fac9 c740 0000 0000 0000 0003 0000 0014  ...@............
    0000040: 4650 5246 0000 0000 0000 0000 0000 0000  FPRF............
    0000050: 0000 002c 4150 5246 0000 0000 0000 0002  ...,APRF........
    0000060: 6d70 3461 0000 0229 0000 0000 0000 0080  mp4a...)........
    0000070: 0000 0080 0000 bb80 0000 0002 0000 0034  ...............4
    0000080: 5650 5246 0000 0000 0000 0001 6176 6331  VPRF........avc1
    0000090: 014d 0028 0002 0002 0000 3e80 0000 3e80  .M.(......>...>.
    00000a0: 001d f853 001d f853 0780 0438 0001 0001  ...S...S...8....
    00000b0: 4ce6 0430 6d64 6174 0000 0002 0910 0000  L..0mdat........
    00000c0: 0013 0600 0d80 afc8 0000 0300 00af c800  ................
    00000d0: 0003 0040 8000 0000 0e06 0109 0000 0824  ...@...........$
    00000e0: 6800 0003 0001 8000 0000 0506 0601 c480  h...............
    00000f0: 0007 390a 2588 8406 454b b57c 50f1 1880  ..9.%...EK.|P...
    0000100: 141b 8c66 f784 77c9 40f2 e916 c558 1d28  ...f..w.@....X.(
    0000110: 1187 f8f9 d0fd b128 1b21 8bc6 44cd 39a3  .......(.!..D.9.
    0000120: 4794 8156 128d 4ce0 8dad e0f5 0210 9d84  G..V..L.........
    0000130: 12fc 9ed4 866e 8736 0444 c9b5 0bc5 4469  .....n.6.D....Di

I then ran `untrunc` against the new file, and it worked!

    $ ./untrunc/untrunc MAH00093.MP4 MAH00094-header.MP4           [18:57:05]
    Reading: MAH00093.MP4
    Composition time offset atom found. Out of order samples possible.
    Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'MAH00093.MP4':
      Metadata:
        major_brand     : MSNV
        minor_version   : 22675568
        compatible_brands: MSNVmp42isom
        creation_time   : 2014-09-10 13:51:22
      Duration: 00:10:40.64, start: 0.000000, bitrate: 16113 kb/s
        Stream #0:0(und): Video: h264 (Main) (avc1 / 0x31637661), yuv420p, 1920x1080 [SAR 1:1 DAR 16:9], 15982 kb/s, 29.97 fps, 29.97 tbr, 30k tbn, 59.94 tbc (default)
        Metadata:
          creation_time   : 2014-09-10 13:51:22
          handler_name    : Video Media Handler
          encoder         : AVC Coding
        Stream #0:1(und): Audio: aac (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 127 kb/s (default)
        Metadata:
          creation_time   : 2014-09-10 13:51:22
          handler_name    : Sound Media Handler
    Begin: 2 9100000Nal type: 9
    : found as avc1
    …

The resulting `MAH00094-header.MP4_fixed.mp4` could play in most players and had basically perfect video. Unfortunately, the video cuts off right before the juicy bit where the camera fell off my bike. I suspect this is because the battery was also ejected from the camera at some point, and the camera didn't get a chance to flush those frames/writes to the SD card before there was power loss.

### Footnotes

[^1]: `untrunc` originally gave me the following error during compilation: `track.cpp:217:8: error: use of undeclared identifier 'avcodec_open'`
