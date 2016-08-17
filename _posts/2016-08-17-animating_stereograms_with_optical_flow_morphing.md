---
title: Animating Stereograms with Optical Flow Morphing
---
Because I've been interested in computer vision, image processing, image registration, and image morphing for a while, ever since I saw the [NYPL's Stereogranimator project](http://stereo.nypl.org/) I've wondered about what it would look like to use [morphing](https://en.wikipedia.org/wiki/Morphing) to visualize historical stereographs. While searching for any previous publications about doing this, I came across an excellent post by Patrick Feaster on [Animating Historical Photographs With Image Morphing](https://griffonagedotcom.wordpress.com/2014/08/18/animating-historical-photographs-with-image-morphing/). This showed me that what I was imagining was both feasible and (to me) provided an uncanny peek into the past that seemed to bring the images alive.

Unfortunately, despite morphing being a long-established technique in image processing, very few automatic processes for image morphing are available in free, open-source implementations. So if you wanted to generate an animated morph, you either had to go through a tedious manual morphing process or know how to implement an automatic morphing algorithm from scratch for the kinds of images you were interested in morphing.

By happenstance,[^happenstance] I came across the [DeepFlow](http://lear.inrialpes.fr/src/deepflow/) [optical flow](https://en.wikipedia.org/wiki/Optical_flow) algorithm and a convenient method for using its output to warp images, via Ruder et al.'s [*Artistic style transfer for videos* paper](http://arxiv.org/abs/1604.08610) and [code](https://github.com/manuelruder/artistic-videos). It was only a matter of simple scripting from there to implement something like the [Beier–Neely morphing algorithm](https://en.wikipedia.org/wiki/Beier%E2%80%93Neely_morphing_algorithm) to gradually apply the optical-flow-based image warp forwards and backwards between two images while cross-dissolving between them.

The resulting code is available [in this repository](https://github.com/ryanfb/torch-warp). I've also published this as [an automated build on Docker Hub](https://hub.docker.com/r/ryanfb/torch-warp/) so you can simply run e.g. `docker run -t -i ryanfb/torch-warp /bin/bash` and it will pull all the necessary Docker images and drop you into a shell. You can then use the provided scripts to automatically generate morphs like this:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">“Cat atop pillow on a tree stump”, ca.1915, via <a href="https://twitter.com/nypl">@nypl</a> <a href="https://t.co/bAKPUYCw6T">https://t.co/bAKPUYCw6T</a> <a href="https://twitter.com/hashtag/InternationalCatDay?src=hash">#InternationalCatDay</a> <a href="https://t.co/omIu8Km5OY">pic.twitter.com/omIu8Km5OY</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/762757154596016128">August 8, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

As a bonus, via looking for other Torch image processing code, I  stumbled across [the code for Izuka et al.'s _Let there be Color!_](https://github.com/satoshiiizuka/siggraph2016_colorization) SIGGRAPH 2016 paper, so you can also experiment with applying automatic colorization to the individual stereo images before morphing:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr"><a href="https://t.co/a3u1zXEgEb">https://t.co/a3u1zXEgEb</a> stereo images separately colorized with <a href="https://t.co/2ihZNku0aD">https://t.co/2ihZNku0aD</a>, then morphed: <a href="https://t.co/yHgq7MipjE">pic.twitter.com/yHgq7MipjE</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/763863200098086913">August 11, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## Uploading GIFs to Instagram

The next step was sharing these images. I wanted something that would loop the animations in relatively high quality, and Instagram seemed like it would work well for that, so I started an ["uncannypast" account on Instagram](https://www.instagram.com/uncannypast/) and have been posting animated morphs there.

To convert GIFs to MP4 for Instagram upload, I use the following cobbled-together `ffmpeg` command:

    ffmpeg -i morphed_output.gif -c:v libx264 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -crf 1 morphed_output.mp4

I then copy the MP4 to Dropbox so that I can use the Dropbox iPhone app to export it to my Camera Roll and import it into Instagram (definitely more convoluted than I'd like, but it works).

## Future Work

For my first passes at testing how the morphing algorithm would work on a large number of stereograms, I wrote a wrapper script (`run-stereogranimator.sh`) that could take an image ID from Stereogranimator in order to download the existing animated GIF and split it into frames to feed into the morphing process. The problem with this is that the GIFs from Stereogranimator are relatively low resolution (usually less than 400x400 pixels), so once they'd gone through a video conversion process (and whatever other conversions happen upon upload), the results looked pretty low quality. To get a really high quality morph animation (> 1000x1000 pixel resolution), I have to download the original stereograph scan in full resolution, then manually crop and align the images I'm going to feed into the morphing process.

I'd really love for an automated process that can do this cropping and aligning process instead. Anyone who's played with Stereogranimator or looked through the results knows there's a "sweet spot" for where this process produces results that are perceptually pleasing, and the same goes for when you feed the images into the morphing process (since I don't yet do any global rigid registration before calculating the optical flow and applying the morph). I have a feeling you could use something with calculating the [epipolar geometry](https://en.wikipedia.org/wiki/Epipolar_geometry) of the stereo views to figure out a potential good alignment. What's needed is this as well as something that can take a scan of a historical stereograph and automatically split/crop it into the component images. As a bonus, something that can _classify_ images as stereograph scans (or not) would be great as well. You could then apply the process end-to-end on vast collections of images, such as those from the Rijksmuseum, which contain a large number of stereographs but no common metadata indicating them. This technique would bring a new dynamic element to discovering, accessing, and visualizing these historical materials.

### Footnotes:

[^happenstance]: I thought it would be a neat idea (and a good way to experiment with deep learning for computer vision) to implement a Twitter bot that would apply artistic style transfer for video to GIFs tweeted at it. That turned out to be a bad idea, because I don't have easy access to a powerful GPU in a Linux environment [and they really aren't kidding when they say the CPU implementation is slow](https://twitter.com/ryanfb/status/758737065852801024).
