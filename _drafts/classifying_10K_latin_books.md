---
title: Classifying 10K Latin(?) Books
---

[David Bamman's recent release of 11K Latin Texts](http://www.cs.cmu.edu/~dbamman/latin.html) got me thinking about how to tackle the problem of the [remaining 10,248 "likely-Latin" texts](https://github.com/dbamman/latin-texts/tree/master/metadata) that [need better metadata](http://chronicle.com/article/Googles-Book-Search-A/48245/).

Luckily Bamman also points to the excellent [`langid.py`](https://github.com/saffsd/langid.py), which seems to work surprisingly well in my testing. My initial idea was to re-run Tesseract OCR processing, with a number of languages specified, including [my preliminary Latin training data](https://ryanfb.github.io/latinocr/) and [Nick White's training data for Ancient Greek](http://ancientgreekocr.org/), and running `langid` on that to prioritize majority-Latin texts. I tried this with a small hand-picked subset:

> <blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/dbamman">@dbamman</a> Example classifications from my script:&#10;<a href="https://t.co/g9t2AWLDkG">https://t.co/g9t2AWLDkG</a> = la&#10;<a href="https://t.co/hYkhvWMFVP">https://t.co/hYkhvWMFVP</a> = nl&#10;<a href="https://t.co/zd8eX91zy1">https://t.co/zd8eX91zy1</a> = en</p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/560518429653102593">January 28, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

This already reveals some complications with the data. Is [the second one](https://archive.org/details/corpusdocumento00frgoog) Dutch, or do we want to count it as Latin? 

Also, it was about this point I realized: there's already some black-box OCR of wildly-varying quality we can use to triage the data, so that we don't need to re-OCR all 10K books. I fetched all the existing OCR text rather inelegantly:

    for i in $(awk '{print $1}' < latin_to_annotate.txt); do echo $i; wget -r -H -nc -np -nH --cut-dirs=2 -A .txt -e robots=off -l1 "https://archive.org/download/$i"; done

This resulted in ~8.6GB of uncompressed text in 9,939 `djvu.txt` files (leaving 489 we'll definitely need to do some further processing on in order to classify). Of these, 10 were just ones that had OCR in erratically named files, which I renamed into `_djvu.txt` manually.[^erratic] (Down to 479 already.)

I then ran `langid` across this set with:

    find . -name '*_djvu.txt' | parallel --bar 'echo $(langid -n < {}) {}' | sort > langs.txt

We can now use `grep -v '^..la' langs.txt | wc -l` to discover there are 2,202 texts which got classified as not-majority-Latin (leaving 7,747 texts trivially—but perhaps erroneously—classified as majority-Latin).

So now we have a variety of texts and classifications:

 * Latin-classified "Latin" texts
 * Latin-classified "non-Latin" texts
 * Non-Latin-classified "Latin" texts
 * Non-Latin-classified "non-Latin" texts

Of particular interest to me here is the problem of identifying "bad OCR" or "bad classification" texts within the last two categories as candidates for further processing and classification, which may also give us a criterion for detecting texts in the second category.

Let's take a non-Latin-classified volume at random; [this volume](https://archive.org/details/corneliischreve00bonwgoog), which was classified as `sq` (Albanian), seems a good choice. Click over to the [full text](https://archive.org/stream/corneliischreve00bonwgoog/corneliischreve00bonwgoog_djvu.txt) and you can see the mess of hot garbage that came out of the OCR process. 

Manually, I would classify this volume as "bad OCR", "not-majority-Latin", "Greek", while still uncertain if it should also count as "Latin". Is there a way we can automatically classify some of this? My first instinct was to use the number of unique languages detected by `langid` inside the file:

    langid --line < ./corneliischreve00bonwgoog/corneliischreve00bonwgoog_djvu.txt | awk '{print $1}' | sort | uniq | wc -l

70 unique languages! Ok, let's check on [a Latin-classified volume](http://archive.org/details/andreaemaximilia00fred) that seems to at least have [something better than random junk for OCR](https://archive.org/stream/andreaemaximilia00fred/andreaemaximilia00fred_djvu.txt):

    langid --line < ./andreaemaximilia00fred/andreaemaximilia00fred_djvu.txt | awk '{print $1}' | sort | uniq | wc -l

61 unique languages. So…maybe not the low-hanging fruit I thought. I also tried the [`ent` utility for measuring entropy](http://www.fourmilab.ch/random/), but there wasn't an obvious distinction (even applied to the whole corpus, or to the distribution of line-based language classification).

Let's try re-running `langid`, restricted to just Latin, without normalizing the confidence scores:

    find . -name '*_djvu.txt' | parallel --bar 'echo $(langid -l la < {}) {}' | sort > langs-la.txt

We can sort these results by "Latin-ness" with:

    awk '{print $2 " " $1 " " $3}' < langs-la.txt | sort -n > langs-la-sorted.txt

Let's sort both score files (Latin-restricted confidence, unrestricted probability) by input filename so we can merge them together and compare them, to see if there's an obvious cutoff we can apply:

    paste <(awk '{print $3 " " $1 " " $2}' < langs.txt | sort) <(awk '{print $3 " " $1 " " $2}' < langs-la.txt | sort) > langs-combined.txt

Now we can use this merged file to get results sorted by "Latin-ness" with their original unrestricted language classification:

    awk '{print $6 " " $2 " " $1}' < langs-combined.txt | sort -n > langs-combined-sorted.txt

Looking at this file, it's clear we're in some murky territory. Let's go back and see what we get when we apply these processes to the already-classified 11,261 texts, so if we can figure out what we want to count as "Latin". Luckily, there's already [a 3.9GB archive of the plain text](https://docs.google.com/uc?id=0B5pGKi0iCsnbZEdHZ3N6d216am8&export=download) kindly provided for us, so we can skip the long `wget` process.

After repeating `langid` processing against these, we can discover that there are 1,561 not-majority-Latin files vs. 9,700 majority-Latin.

### Footnotes

[^erratic]: Found with `find . -name '*.xml_meta.txt' -exec rm {} \;` to remove `xml_meta.txt` files, then `find . -name '*.txt' | grep -v djvu`.
