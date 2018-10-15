---
title: Language Identification on HTRC Extracted Features
tags:
- ocr
---

The [HTRC Extracted Features Dataset](https://analytics.hathitrust.org/datasets) is a valuable resource for anyone interested in doing large-scale text analysis. Because of my work in [Latin OCR](http://latin-ocr.github.io/), Latin volumes in HathiTrust are of particular interest to my research. Selecting [a Latin volume that I knew of from data I was already working with](https://twitter.com/ryanfb/status/702979693012647936), I noticed that the page-level "language" metadata was pretty bad, frequently detecting Portuguese as the page language when the majority of OCR tokens were very recognizably Latin. It seems like [the language detection library used by HTRC](https://code.google.com/archive/p/language-detection/) isn't trained against Latin, so I thought it might be useful to re-process page tokens with [langid](https://github.com/saffsd/langid.py).

I noticed that for the Latin volume I selected, while the page-level language metadata was wrong, the volume-level language metadata was correct. Since I'm mostly interested in Latin volumes (and didn't want to find 1.2TB of free space for the full set of basic features on all volumes), I decided to use the language specified in the bibliographic metadata as an initial filtering criterion. I did this by downloading [the bulk bibliographic data export HathiTrust makes available](https://www.hathitrust.org/hathifiles), and [filtering to Latin](https://gist.github.com/ryanfb/2c0461327be04a9f9989) with:

    awk -F $'\t' 'BEGIN {OFS = FS} { if ($19 == "lat")  print }' hathi_full_20160301.txt > hathi_latin_ids.tsv

I then downloaded the list of HTRC basic feature files, and filtered it down to [just the Latin volumes](https://gist.github.com/ryanfb/fae4c6cc2acbf2b0c9e6) I got from the bibliographic data with:

    cut -f1,1 < hathi_latin_ids.tsv > latin_ids_only.txt
    grep -F -f latin_ids_only.txt pd-basic-file-listing.txt > pd-basic-latin.txt

I could then `rsync` all these feature files with:[^rsync]

    rsync -av --files-from pd-basic-latin.txt data.sharc.hathitrust.org::pd-features/ latin/

Which gave me about 53GB of compressed JSON. I then wrote a short, dumb script to mash strings generated from the page tokens into `langid` and write the results to CSV:

<script src="https://gist.github.com/ryanfb/2d1571135cdee86d22ad.js"></script>

Which I then ran with:

    find ../latin -name '*.bz2' | parallel -u -j8 -X ../sharclangcountbz2.py

For anyone interested, [here's a link to a `.tar.bz2` of the resulting CSV files](https://duke.box.com/shared/static/w4pqr2kwqvueqf9t9w3e5nnxxp2bpuy8.bz2) (17.6MB).

We can then do things like find [the majority page language for each volume](https://gist.github.com/ryanfb/f1ae896e99e6df66145c) and then see what [the language distribution is](https://gist.github.com/ryanfb/dd62e30969759b714ca2):

    find langid -name '*.csv' | while read csvfile; do echo "$(basename ${csvfile} .csv),$(cut -d, -f1,1 $csvfile|sort|uniq -c | sort -rn|head -1|sed -E 's/^ *[0-9]+ //g')"; done > toplangs.csv
    cut -d, -f2,2 toplangs.csv|sort|uniq -c|sort -rn > lang-distribution.txt

Or do the same thing at [the page level](https://gist.github.com/bb44cabfd69b77fd6752):

    find langid -name '*.csv' -print0 | xargs -0 cat | cut -d, -f1,1 | sort | uniq -c | sort -rn > page-lang-distribution.txt

Note that the results still depend on the tokens we get from the OCR. Since we don't restrict the language set used by `langid`, we wind up with some odd things like 7,512 volumes detected as "Luxembourgish". Spot-checking these it seems like this (and other obscure languages) [often winds up being a kind of proxy for "bad OCR"]({{ site.baseurl }}{% post_url 2015-03-16-automatic_evaluation_of_ocr_quality %}).

I'd also like to run this processing against the full feature dataset and release the results, though this may take a while longer and I'd like to incorporate any feedback I get from this work into that process. Watch this space!

### Footnotes:

[^rsync]: I strongly suggest checking that you're using `rsync` 3.x if you're going to do this sync yourself.
    <blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">OS X still ships with rsync 2.6.9. Homebrew has 3.1.2.<br>2.x sat for 6+ hours just getting the file list, while 3.x started xfer immediately.</p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/705201292419973120">March 3, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
