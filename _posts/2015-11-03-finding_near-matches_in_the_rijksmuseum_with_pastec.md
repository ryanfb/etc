---
title: Finding Near-Matches in the Rijksmuseum with Pastec
---
I've been interested in experimenting with [content-based image retrieval (CBIR)](https://en.wikipedia.org/wiki/Content-based_image_retrieval) on large humanities datasets for a while, and [John Resig](http://ejohn.org/) brought [Pastec](http://pastec.io/) to my attention in [the Digital Humanities Slack](https://docs.google.com/forms/d/1u9CE8vV7ac8-OK2n8roiURvWoO0dpQuzNBWMOaaRXik/viewform). [Ed Summers](https://twitter.com/edsu) wondered if there might be something interesting to do with it in the context of [Matthew Lincoln's Rijksmuseum Images Torrent](http://matthewlincoln.net/2015/10/19/the-rijksmuseum-as-bittorrent.html) and I thought it would be a perfect opportunity to put Pastec through its paces.

Like [TinEye MatchEngine](https://services.tineye.com/MatchEngine), Pastec aims to find duplicate and near image matches in large image collections. Unlike MatchEngine, Pastec is [open source](https://github.com/visu4link/pastec), and uses [ORB image descriptors](http://scikit-image.org/docs/dev/auto_examples/plot_orb.html) to find matches among images.[^matchengine]

[The Pastec API](http://pastec.io/doc#api) is pretty spare, but it seemed like there was enough there to do what I wanted. After getting the Pastec server compiled and running, I started bouncing every image in the Rijksmuseum data set into it with:

    i=0; find rkm_data/images -type f | while read image; do \
      curl -X PUT --data-binary @$image http://localhost:4212/index/images/$i; \
      i=$((i+1)); \
    done

Because of the way the Pastec API works, I also needed to keep a corresponding image file to index identifier mapping with:

    i=0; find rkm_data/images -type f | while read image; do \
      echo "$i,$image"; \
      i=$((i+1)); \
    done > mapping.csv

The process of adding all 218,442 images to the index took about two days,[^specs] and resulted in a ~1.8GB index file. Once the index was finished, I needed to then bounce all the images back through the search API to find matches:

    find rkm_data/images -type f -name '*.jpeg' | \
    parallel --bar -u -j 8 \
    'curl -s -X POST --data-binary @{} http://localhost:4212/index/searcher' \
    > pastec_matches.txt

This process took about four days to complete. At the end, I wanted to mash the matches up with the filenames to make the results more easily usable, while also filtering the results down to "unique" matches with more than one image (i.e. a given set of `image_ids` should appear only once in the results), which I wrote a short script to do:

<script src="https://gist.github.com/ryanfb/b66e4f7536dbdfa5df5f.js"></script>

This resulted in 33,029 "unique" matches in the set.

Dipping into the results at random demonstrates a wide variety of the types of matches Pastec catches. From multiple versions of a print:

> <blockquote class="twitter-tweet" data-conversation="none" lang="en"><p lang="en" dir="ltr">About a day left for indexing of the Rijksmuseum images to finish. Duplicate detection seems to work well already! <a href="https://t.co/brrkmHt4As">pic.twitter.com/brrkmHt4As</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/659082754974457856">October 27, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

To a set of images of the galleries with a bench photographed from approximately the same angle:

> <blockquote class="twitter-tweet" data-conversation="none" lang="en"><p lang="en" dir="ltr">While we wait for image matching to complete, you can surf the <a href="https://twitter.com/rijksmuseum">@rijksmuseum</a> galleries on this comfy bench: <a href="https://t.co/kQtotER6tt">pic.twitter.com/kQtotER6tt</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/660119262523183104">October 30, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

To two anonymous and quite-similar plates:

> <blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">Just 1 of the 33,029 &quot;unique&quot; matches among the Rijksmuseum images:&#10;<a href="https://t.co/T1PdVEd3Pw">https://t.co/T1PdVEd3Pw</a>&#10;<a href="https://t.co/mmP8LACNBq">https://t.co/mmP8LACNBq</a> <a href="https://t.co/KIGYYGflC7">pic.twitter.com/KIGYYGflC7</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/661571540438360064">November 3, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Another phenomenon I've noticed is large match sets where the images mostly have e.g. a ColorChecker calibration target in common between them. At first I thought I could filter this out by the dimensions of the match results, or the match scores. Unfortunately, the match dimensions still cover most of the image in many of these cases, and the scores are not easily thresholdable without discarding valid matches (for example, the plates above have a match score of 14, and many ColorChecker matches have a score higher than this).

So what can we do with this data, and with this sort of processing? For one, I think it would be an interesting way to enable "serendipity" in large digital image collections. Some Rijksmuseum objects have a "Related Objects" metadata field which occasionally captures some of the matches found by this process, but many do not; this sort of automatic related object discovery could supplement this (presumably manually-generated) metadata. We could also invert this and use the "related" metadata to examine the results of our automatic process and see what kind of related objects image-matching doesn't discover. John has also shared [some interesting results that he got with using MatchEngine across multiple image archives](https://www.youtube.com/watch?v=PL6J8MtTsPo&t=27m8s), and it might be similarly-interesting to match other archives against the Rijksmuseum or vice versa.

I've been toying with the idea of setting up a Twitter bot to go through and tweet GIFs of every "unique" match (ideally with the Rijksmuseum URLs associated with them as well, so that they can be discovered via Twitter search). However, for this process to take even a little under a year, it would still need to tweet four images per hour without interruption, which may be a little much for anyone to realistically follow without it being too much spam.

Doing the processing also turned up some issues with the processing and the data, as it typically does. We might want to try to automatically crop out calibration charts before indexing with Pastec, for example.[^colorchecker] We might also want to improve the performance of Pastec search so that we can run this process more frequently and on a wider variety of large image sets.[^scaling] Doing the processing also revealed an issue with some of the data in the torrent, that there are actually 13,101 empty image files in the uncompressed data, and most of these correspond to objects where the Rijksmuseum API does not make an image available due to copyright restrictions.[^missing]

For now, I'd like to make the match and index data available to anyone who wants to experiment with them:

 * [`rijks.dat.bz2`](https://duke.box.com/shared/static/7fu21mn7ek4v96ic7h3wy1pnagtoyz78.bz2) (~1.5GB) - the Pastec index built from the uncompressed Rijksmuseum torrent, which should be [loadable into another Pastec server instance](http://pastec.io/doc#setup).
 * [`mapping.csv.bz2`](https://duke.box.com/shared/static/9y9x0rw531uioskgp7rr716lfxrm4bje.bz2) (792KB) - the mapping from Pastec index number to uncompressed Rijksmuseum torrent filename.
 * [`pastec_matches.txt.bz2`](https://duke.box.com/shared/static/wdmxd8a3k2h5u8q47t92ct0kaojgf6wx.bz2) (3.1MB) - the output from the Pastec search process described above.
 * [`unique_matches_min.json.bz2`](https://duke.box.com/shared/static/v76x0w2v19dwrnipvrkllbv85rpzrp5r.bz2) (1.3MB) - minified JSON output with the 33,029 "unique" matches from the `mash_matches.rb` script above.

### Footnotes:

[^matchengine]: John also has some great work on using MatchEngine for this sort of thing available online: <http://ejohn.org/research/>.
[^specs]: All the Pastec indexing and searching was done on an iMac with a 3.5GHz Intel Core i7 CPU and 32GB of RAM.
[^colorchecker]: I hadn't considered using the process for calibration chart _removal_ before, but my [survey of automatic ColorChecker detection approaches]({{ site.baseurl }}{% post_url 2015-07-08-automatic_colorchecker_detection %}) might provide a good starting point for anyone looking to do this.
[^scaling]: You could presumably scale up Pastec by building the monolithic index once, then distributing the built index across a number of server instances and partitioning the search across them, but I'd really like to see performance be faster within a single instance.
[^missing]: Six of these missing images do appear to be downloadable, and I've made a list of these available [here](https://gist.github.com/ryanfb/c16f26b96a86ab775873), though I did not add them to my Pastec index.
