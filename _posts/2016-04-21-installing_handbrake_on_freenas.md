---
title: Installing HandBrake on FreeNAS
---

I wanted to be able to rip/encode my DVD collection for my Plex server running on FreeNAS 9.3.[^freenas910] This was a little less than straightforward, so here's a quick guide to what I needed to do to get it working:

* Create a `handbrake` jail from the FreeNAS web GUI. For the following steps, bring up a shell inside the jail using the web GUI or find the jail number with `jls` then use `jexec NUM /bin/tcsh`.
* Use the `pkg` system to install HandBrake and related utilities:
  * `pkg upgrade`
  * `pkg install handbrake libass ffmpeg x265 libaacs libbdplus`
* Use the Ports collection to install `lame` and `libdvdcss`:
  * `portsnap fetch extract`
  * `cd /usr/ports/audio/lame && make install clean`
  * `cd /usr/ports/multimedia/libdvdcss && make install clean`

Now you should be able to run `HandBrakeCLI` without error. By default, my DVD drive was at `/dev/cd0` and mapped within the jail.

I use the following for movies, and [this script (requires `bash`)](https://gist.github.com/ryanfb/ee31af4bf611ff707d9b) to loop through all titles on a TV DVD:

    HandBrakeCLI --main-feature -i /dev/cd0 -o movie.mkv -e x265 -q 23 --encoder-preset slow -E av_aac --custom-anamorphic --keep-display-aspect -O -Neng -s1 --decomb

### Footnotes:

[^freenas910]: The same instructions should work for FreeNAS 9.10, but because [I'd have to destroy/recreate all my jails to use the 9.10 jail templates](https://forums.freenas.org/index.php?threads/freenas-9-10-release-now-available.42223/), I haven't tested this yet.
