---
title: Finding Near-Matches in the NYPL with Pastec
---

Following up on my previous post on [finding visually-similar images in the Rijksmuseum with Pastec]({{ site.baseurl }}{% post_url 2015-11-03-finding_near-matches_in_the_rijksmuseum_with_pastec %}), I thought it would be interesting to apply the same techniques to [the New York Public Library's recent release of 180,000+ public domain images](http://www.nypl.org/research/collections/digital-collections/public-domain). After tweaking some [tools](https://github.com/NYPL-publicdomain/pd-visualization) to download the images associated with the data, I again built a [Pastec](http://pastec.io/) index of the images and searched for matches within the collection. The results should be downloadable here:

* [`nypl.dat.bz2`](https://duke.box.com/s/y6yhui8yiyymmndg4q1opmf6pu14hc0g) (1.14GB) - the Pastec index built from the downloaded images, which should be [loadable into another Pastec server instance](http://pastec.io/doc#setup).
* [`mapping.csv.bz2`](https://duke.box.com/s/y7g1on5mh0vz28w6i13ac2lfk8nu7o4s) (687KB) - the mapping from Pastec index number to NYPL image ID.
* [`pastec_matches.txt.bz2`](https://duke.box.com/s/4qjvlrssxfxz7m5ki9umylz83a5ltapw) (4.7MB) - the output from the Pastec search process.
* [`unique_matches.min.json.bz2`](https://duke.box.com/s/bwoc2186dw6vkjwm6echeoza89t67ith) (3MB) - minified JSON output with the 35,195 "unique" matches from the `mash_matches.rb` script in the Rijksmuseum post.

One facet made apparent by this process is the differences in the within-collection match results between the Rijksmuseum and the NYPL. Using the same process I'm using to [automatically post GIFs of the Rijksmuseum matches to Tumblr](http://rijksmuseum-pastec.tumblr.com/) let me do the same to generate GIFs for the NYPL's "unique" matches to get a sense for what was being matched. The first thing that struck me from this was the size of the results: despite having only 2,166 more "unique" matches, the NYPL GIF output was a massive 134GB compared to the Rijksmuseum's 40GB. Of these, 10,230 (out of 35,195) exceeded Tumblr's 2MB upload limit, compared to 2,532 (out of 33,029) for the Rijksmuseum. So we have a lot more matches where the *number* of matches to other items within the collection is greater.

By looking at the resulting images, it also quickly becomes apparent that the *types* of matches found are also very different. While the Rijksmuseum matches are mostly prints, objects, and photographs, the majority of the NYPL matches fall into a few different categories, where the visual similarity (according to Pastec, at least) of items within these categories results in the very different distribution of matches found:

* [Stereographs](http://stereo.nypl.org/) (often multiple prints of the same image, but sometimes [different stereographs of the same scene](https://twitter.com/ryanfb/status/693205214489346048))
* Military uniform illustrations, e.g. [the Vinkhuijzen collection](http://digitalcollections.nypl.org/collections/the-vinkhuijzen-collection-of-military-uniforms#/?tab=navigation)
* [Restaurant menus](http://menus.nypl.org/)
* Maps and [floorplans](http://digitalcollections.nypl.org/collections/apartment-houses-of-the-metropolis#/?tab=about)
* [Songbooks](http://digitalcollections.nypl.org/collections/american-popular-songs#/?tab=navigation)

Subtracting some of these types of objects might winnow things down to some of the more interesting matches, depending on what you're interested in.

Another thing I did with this data was to try matching the NYPL images against the Rijksmuseum index, to try to find matches between the two collections. That resulted in 1,329 matches, which I've made available as [a clickable Google Docs spreadsheet](https://docs.google.com/spreadsheets/d/1BCcwzS1mEIG-xm7kfKDnf4fG5FW01MB30elCLJQvS-w/edit) (which you can also download as CSV).

Ultimately, both of these experiments suggest to me that it might be useful to use a process like this to surface related items within digital collections when images are available. I've come across many matches turned up by this process which would be helpful to know about when looking at any of the objects contained in the match set, but would be nearly impossible to find manually from the existing metadata. It might also be interesting to merge multiple indexes together to achieve something like a "Cultural Heritage TinEye" (imagine also adding images from Europeana, WikiMedia Commons, etc.).
