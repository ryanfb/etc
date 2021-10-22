---
title: Printing Public Domain Books on Lulu
---
I've been interested in printing my own personal copies of some public domain works for a while with a print-on-demand service, and wound up wanting some printed copies of the reference edition of [Stobaeus](https://en.wikipedia.org/wiki/Stobaeus) for reading and working with.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Extremely niche offering, but I’m about to try getting all five volumes of the (public domain) Wachsmuth &amp; Hense Stobaeus printed for myself on Lulu as cheap paperbacks if anyone else on <a href="https://twitter.com/hashtag/ClassicsTwitter?src=hash&amp;ref_src=twsrc%5Etfw">#ClassicsTwitter</a> is interested <a href="https://t.co/Hf7zucpHFa">https://t.co/Hf7zucpHFa</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/1448674050348302343?ref_src=twsrc%5Etfw">October 14, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

This seemed as good an opportunity as any, and I went with [Lulu](https://www.lulu.com/) since I had purchased some books for sale there before, where a seller had cleaned up public domain editions I wanted a physical copy of (I may make the corrected versions of my Stobaeus prints available for general purchase later on Lulu, and if I do so I'll update here).

Since the process of going from PDFs on the [Internet Archive](https://archive.org) to something that's actually printable was not at all intuitive, I thought I would document what I had to do in case it could be of use to others. There may be some additional formatting steps I didn't encounter, feel free to let me know if you have to do any additional workarounds.

The first issue with uploading the PDFs to Lulu was that I wanted to remove e.g. scans of the book cover and leading/trailing material that I didn't want in the reprint. Luckily I'm already familiar with a tool for this; [`pdftk` server](https://www.pdflabs.com/tools/pdftk-server/) is a command-line PDF manipulation tool. By using the `cat` command I could slice a range of pages, e.g.:

    pdftk joannisstobaeian01stovuoft_bw.pdf cat 1-546 output joannisstobaeian01stovuoft_bw_vol_1.pdf

However, I still encountered various errors when uploading the PDF to Lulu. One was that embedded fonts were missing; this could either be solved by removing all embedded font references or by embedding referenced fonts into the PDF, I chose the latter. The easiest tool I found for this was [Coherent PDF's `cpdf` utility](https://www.coherentpdf.com/):

    cpdf -gs $(which gs) -embed-missing-fonts joannisstobaeian01stovuoft_bw_vol_1.pdf -o joannisstobaeian01stovuoft_bw_vol_1_embed_fonts.pdf

The next issue was that I needed to size the PDF to the exact print size I wanted on Lulu. For this, you'll need to reference the [Lulu book creation guide PDF](https://assets.lulu.com/media/guides/en/lulu-book-creation-guide.pdf). For example, I decied I wanted a "US Trade" trim size: `152mm x 229mm`. I needed to convert `mm` to `pts` for the `cpdf` command, so using [an online converter](https://www.conversionunites.com/converter-mm-to-points) I got `431pts x 649pts` which I could use with `cpdf` to resize to fit:

    cpdf -scale-to-fit "431 649" joannisstobaeian01stovuoft_bw_vol_1_embed_fonts.pdf -o joannisstobaeian01stovuoft_bw_vol_1_scaled.pdf

Uploading that file and checking it, everything looked good, so I did a similar process for the remaining volumes. Everything turned out pretty well overall:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Loebs? Where we’re going, we don’t need Loebs <a href="https://t.co/idWRDTRgh3">pic.twitter.com/idWRDTRgh3</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/1451247886247899136?ref_src=twsrc%5Etfw">October 21, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Seems fine to me as far as margins/trim/gutter go (which were my main concern for screwups), quality is about as expected (perfect/glue binding), &amp; I messed up on the very last volume not checking if I needed to insert any spacer pages to preserve left/right pages <a href="https://t.co/tYQ0mBf66f">pic.twitter.com/tYQ0mBf66f</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/1451253011569909761?ref_src=twsrc%5Etfw">October 21, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

So with the caveat that for a second or public run I would fix the page offset for the last volume, this is a pretty handy reference set of an otherwise practically unobtainable set of physical reference editions. Most of the existing ones out there are print-on-demand of incomplete sets of editions in any case, so you might as well know what you're getting and that you can get a complete set!
