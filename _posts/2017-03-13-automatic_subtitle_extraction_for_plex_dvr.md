---
title: Automatic Subtitle Extraction for Plex DVR
---

I've been playing with [Plex DVR](https://www.plex.tv/features/dvr/) with my HDHomeRun Prime for recording TV shows, and one thing that's missing in the default processing options is a way to get at the subtitle (or closed-caption) data that's there in the original video stream. Figuring out how to have those subtitles show up in Plex wasn't straightforward, so I thought I'd write up how I did it.

First, you need to install [CCExtractor](https://www.ccextractor.org/) on your Plex server. If your OS has a packaged/built version of CCExtractor available, I strongly recommend using that. You'll also need to install [FFmpeg](https://ffmpeg.org/).

Next, you need to set up Plex with the right DVR recording options for CCExtractor to work, and then hook up subtitle extraction as part of a DVR recording post-processing script for Plex.

For subtitle extraction to work best, set "Convert Video While Recording" to "Off" (in your Plex server, Settings, DVR, Device Settings). "Remux Only" may also work if you're not doing anything else like automatic commercial skipping. "Transcode" loses the subtitle data. In any case, we'll remux to MKV later, so we don't necessarily need remuxing on-the-fly.

Next, you'll need to make a shell script that's executable/accessible by Plex. I'm using this in conjunction with [PlexComskip](https://github.com/ekim1337/PlexComskip) for automatic commercial removal, and do the subtitle extraction and remuxing after that. The key takeaway is that the Plex post-processing script *can only leave one file* in the original video directory, so what we do is use `ccextractor` to extract the subtitles from the video transport stream into the more common SRT format, then use `ffmpeg` to remux the subtitles with the video/audio into a single MKV file.

My script (set in the Plex DVR settings) looks like this:

<script src="https://gist.github.com/ryanfb/fb3ba54cc4be8ac547f38fd91ae74f03.js"></script>

You may need to tweak things depending on your paths/configuration/language. I'd suggest logging the output of the script somewhere and setting some test recordings to make sure everything works as expected.
