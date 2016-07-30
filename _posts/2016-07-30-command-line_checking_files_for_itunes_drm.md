---
title: Command-Line Checking Files for iTunes DRM
---

I wanted to check all the files (Music, Movies, TV Shows) in my iTunes library for DRM, but all the solutions I found with cursory Googling involve manually checking the media info from the iTunes GUI instead of something which can be done in batch from the command line.

Looking at the [`mediainfo`](https://mediaarea.net/)[^mediainfo] output for various DRM'd files, I noticed the common denominator for iTunes-DRM'd files was the `AppleStoreAccount` field. So we can just `fgrep` for the presence of this field in `mediainfo`'s output, and if the command succeeds the file is DRM-protected.

From inside your iTunes Library folder, you can list all files that have DRM with something like this:

    find . -type f | while read file; do \
      mediainfo $file | fgrep AppleStoreAccount > /dev/null; \
      if [ $? -eq 0 ]; then echo $file; fi; \
    done > ~/drmfiles.txt

### Footnotes:

[^mediainfo]: You can install the `mediainfo` command line interface on a Mac with `brew install mediainfo` if you have [Homebrew](http://brew.sh/) installed.
