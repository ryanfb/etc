---
title: Filtering video frames by sharpness for photogrammetry
tags:
- photogrammetry
---

Sometimes when [processing video for 3D photogrammetry]({{ site.baseurl }}{% post_url 2014-10-22-drone_photogrammetry_workflow %}), you want to reduce the number of frames used in order to reduce the processing time or fit within a limit.[^recap360] You may also want to [reduce the number of blurry frames used](https://groups.google.com/forum/#!searchin/vsfm/video/vsfm/3nplT9Tmyuw/56UAm497oaMJ), as this can result in noise or errors with some reconstruction processes.

From [this Stack Overflow answer on image sharpness](http://stackoverflow.com/a/26014796) I adapted the following Python code:

<script src="https://gist.github.com/ryanfb/1fee5bda078c786d21f0.js?file=sharpness.py"></script>

You can then process all your frame images with e.g.:

    parallel --bar --line-buffer -j8 './sharpness.py {}' ::: *.jpg | sort -gr > sharpness.txt

I also wrote a complementary Python script designed to [greedily](http://en.wikipedia.org/wiki/Greedy_algorithm) filter this output into a target number of frames (optionally thresholded by a user-supplied cutoff), assuming there's a single integer in each filename with the frame number and we'd prefer an even distribution of frames:

<script src="https://gist.github.com/ryanfb/1fee5bda078c786d21f0.js?file=filterlist.py"></script>

You can then copy, say, the 500 sharpest frames out of 5,000 with a minimum "sharpness" threshold of 2.0 out to a directory for photogrammetry processing with:

    cp -v $(./filterlist.py 500 2.0 < sharpness.txt) sharp/

### Footnotes

[^recap360]: [Autodesk ReCap360](https://web.archive.org/web/20160325145302/https://recap.autodesk.com/), for example, [limits you to 50 input images for the free "Preview" mode](http://forums.autodesk.com/t5/photo-on-recap360/image-number-limit/td-p/51/28256).
