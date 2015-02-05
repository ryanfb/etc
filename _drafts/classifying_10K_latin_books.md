---
title: Classifying 10K Latin(?) Books
---

[David Bamman's recent release of 11K Latin Texts](http://www.cs.cmu.edu/~dbamman/latin.html) got me thinking about how to tackle the problem of the [remaining 10,248 "likely-Latin" texts](https://github.com/dbamman/latin-texts/tree/master/metadata) that [need better metadata](http://chronicle.com/article/Googles-Book-Search-A/48245/).

Luckily Bamman also points to the excellent [`langid.py`](https://github.com/saffsd/langid.py), which seems to work surprisingly well in my testing. My initial idea was to re-run Tesseract OCR processing, with a number of languages specified, including [my preliminary Latin training data](https://ryanfb.github.io/latinocr/) and [Nick White's training data for Ancient Greek](http://ancientgreekocr.org/), and running `langid` on that to prioritize majority-Latin texts. I tried this with a small hand-picked subset:

> <blockquote class="twitter-tweet" data-conversation="none" lang="en"><p><a href="https://twitter.com/dbamman">@dbamman</a> Example classifications from my script:&#10;<a href="https://t.co/g9t2AWLDkG">https://t.co/g9t2AWLDkG</a> = la&#10;<a href="https://t.co/hYkhvWMFVP">https://t.co/hYkhvWMFVP</a> = nl&#10;<a href="https://t.co/zd8eX91zy1">https://t.co/zd8eX91zy1</a> = en</p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/560518429653102593">January 28, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

This already reveals some complications with the data. Is [the second one](https://archive.org/details/corpusdocumento00frgoog) Dutch, or do we want to count it as Latin? 

Also, it was about this point I realized: there's already some black-box OCR of wildly-varying quality we can use to triage the data, so that we don't need to re-OCR all 10K books. I fetched all the existing OCR text rather inelegantly:

    for i in $(awk '{print $1}' < latin_to_annotate.txt); do echo $i; wget "https://archive.org/download/$i/${i}_djvu.txt"; done

This resulted in ~8.6GB of uncompressed text in 9,936 `djvu.txt` files (leaving 312 we'll definitely need to do some further processing on in order to classify).

I then ran `langid` across this set with:

    find . -name '*_djvu.txt' | langid -b > djvus-language-confidence.txt

We can now use `cut -d, -f2 < djvus-language-confidence.txt | grep -v la | wc -l` to discover there are 2,199 texts which got classified as not-majority-Latin (leaving 7,736 texts trivially—but perhaps erroneously—classified as majority-Latin).[^classifications]

[^classifications]: What we have at this point are actually a variety of texts and classifications:
    
     1. Latin-classified "Latin" texts
     2. Latin-classified "non-Latin" texts
     3. Non-Latin-classified "Latin" texts
     4. Non-Latin-classified "non-Latin" texts
    
    Of particular interest to me here is the problem of identifying "bad OCR" or "bad classification" texts within the last two categories as candidates for further processing and classification, which may also give us a criterion for detecting texts in the second category. But that's a problem for another day...

Let's try re-running `langid`, restricted to just Latin in order to gage the "Latin-ness" of each file:

    find . -name '*_djvu.txt' | langid -b -l la > djvus-latin-confidence.txt

We can also sort these results by "Latin-ness" with:

    awk -F, '{print $3 "," $2 "," $1}' < djvus-latin-confidence.txt | sort -g > djvus-latin-confidence-sorted.txt

Let's sort both score files (unrestricted & Latin-restricted) by input filename so we can merge them together and compare them, to see if there's an obvious metric we can apply:[^substitution]

    paste -d, <(sort < djvus-language-confidence.txt) <(sort < djvus-latin-confidence.txt) > djvus-combined-confidence.txt

Now we can use this merged file to get results sorted by "Latin-ness" with their original unrestricted language classification and score:

    awk -F, '{print $6 "," $2 "," $3 "," $1}' < djvus-combined-confidence.txt | sort -g > djvus-combined-confidence-sorted.txt

Looking at this file, it's clear we're in some murky territory. Let's go back and see what we get when we apply these processes to the already-classified 11,261 texts. Luckily, there's already [a 3.9GB archive of the plain text](https://docs.google.com/uc?id=0B5pGKi0iCsnbZEdHZ3N6d216am8&export=download) kindly provided for us, so we can skip the long `wget` process.

After repeating `langid` processing against these,[^make] we can discover that there are 1,561 not-majority-Latin files vs. 9,700 majority-Latin, not wildly far off from the ratio we have.

[^make]: It was around this point I decided I would be well-served by writing a `Makefile` and rules for repeatably/generically applying this processing. I've published the results of this on [a separate `classification` branch on my fork of `latin-texts`](https://github.com/ryanfb/latin-texts/tree/classification/metadata).

Instead of trying to automatically decide what is or is not "Latin" (I think ultimately a human has to decide that, depending on the goals or intended uses of the final data/corpus), what I'd like to do is come up with a way to use this data to prioritize entries that need metadata by "Latin-ness" (i.e. which texts will give us *the most Latin* for our investment?).

We could simply sort by the existing "Latin-ness" measure straight out of `langid`, but looking at these (with the additional help of a "control" set obtained by also applying our processing to the predominantly-English [Internet Archive "Great Books" collection](https://archive.org/details/greatbooks)) it's clear that the `langid` confidence score is heavily influenced by input length. Now, `langid` has an option to normalize scores to probabilities, but in my testing this normalized probability is not very meaningful when you restrict to just one language.

What we want, then, is to take into account both confidence scores and the length of the work. The measure I came up with for this is simply the difference of the scores divided by the number of lines:

    find . -name '*_djvu.txt' -exec wc -l {} \; | awk '{print $1 "," $2}' | sort -n > djvus-lines.txt
    paste -d, <(sort < djvus-language-confidence.txt) <(sort < djvus-latin-confidence.txt) <(awk -F, '{print $2 "," $1}' < djvus-lines.txt | sort) > djvus-combined-confidence-lines.txt
    awk -F, '{diff = sprintf("%.3f",($1 - $3) / $5); print diff "," $5 "," $1 "," $2 "," $3 "," $4 }' < djvus-combined-confidence-lines.txt | sort -gr -t, -k1,1 -k2,2  > djvus-combined-confidence-diff-sorted.txt

This gives us the list sorted by our normalized difference then sorted by the length; so Latin-classified works will appear at the top (as the difference is zero), sorted by length, followed by the rest.

Now we just need to merge these results back with our original. This wound up being pretty tortuous to do with the command line, so if you're interested you can see [the `Makefile` rules I came up with for it here instead](https://github.com/ryanfb/latin-texts/blob/classification/metadata/Makefile#L44-L63). At the end of all this is [a nice prioritized list of the identifiers](https://github.com/ryanfb/latin-texts/blob/sort/metadata/latin_to_annotate.txt).

More importantly, we have a repeatable, stable process for generating this classification and prioritization. So now, after I go back and apply OCR processing to the remaining identifiers for which there was no existing OCR text, I can easily sort them back into the right place in the list.

### Footnotes

[^erratic]: Found with `find . -name '*.xml_meta.txt' -exec rm {} \;` to remove `xml_meta.txt` files, then `find . -name '*.txt' | grep -v djvu`.
[^substitution]: The `<( )` syntax seen here is a useful technique known as [process substitution](http://tldp.org/LDP/abs/html/process-sub.html).
