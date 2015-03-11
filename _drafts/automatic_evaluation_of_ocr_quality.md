---
title: Automatic evaluation of OCR quality
---

Following my [previous post on classifying 10K Latin(?) books]({{ site.baseurl }}{% post_url 2015-02-05-classifying_10K_latin_books %}), I started [an automatic process to re-OCR the ~300 works in the set which didn't have plaintext OCR results already available](https://github.com/ryanfb/latin-texts-ocr). About mid-way through the run of this process, I realized that most of these do in fact have some form of OCR available, but only as DjVu XML output from ABBYY FineReader. That means that not only can we potentially use that OCR text for our text classification process, but also that we can compare how that process works with ABBYY's OCR text versus our OCR results.

This leads me in to the actual problem I want to deal with in this post, which is trying to come up with a method for automatically evaluating OCR quality with no ground truth. Anyone who's worked with OCR of historical texts knows bad OCR when they see it, but can we come up with a more general approach we can automatically apply to an entire corpus, to automatically find and prioritize candidates for reprocessing? [^underwood]

## Related Work

A lot of work has been published on OCR post-correction processes, or quantifying OCR accuracy with ground truth, but I wanted to focus solely on standalone ground-truth-free quality metrics for OCR, for which there appears to be relatively less work published: [^poco]

* Ashok C. Popat, [*A Panlingual Anomalous Text Detector*](http://dl.acm.org/citation.cfm?id=1600237). Proceedings of the 9th ACM symposium on Document engineering. 2009.

  Uses an adaptive mixture of character-level N-gram models, which must be trained per-language.
* Richard Wudtke et al., [*Recognizing Garbage in OCR Output on Historical Documents*](http://dl.acm.org/citation.cfm?id=2034626). Proceedings of the 2011 Joint Workshop on Multilingual OCR and Analytics for Noisy Unstructured Text Data. 2011.
  
  [SVM](https://en.wikipedia.org/wiki/Support_vector_machine)-based approach which requires a manually classified garbage/non-garbage token training set.
* Ulrich Reffle et al., [*Unsupervised profiling of OCRed historical documents*](http://www.sciencedirect.com/science/article/pii/S0031320312004323). Pattern Recognition Vol. 46, Issue 5, pp.1346–1357. 2013.
  
  A somewhat complicated approach which makes re-implementation not straightforward. It also requires large corpora and lexica for the languages of interest. I was hopeful that there might be an implementation of the algorithm in the open-source [PoCoTo](https://github.com/thorstenv/PoCoTo), however, this appears to use a client-server model for error profiling, where you must register for an account to have a profiling server generate error profiles for you. I couldn't find the source for this server, and I doubt that this would work well for my needs due to there being an error profiling quota. I also don't know if their implementation would work well where Latin is the "base" text rather than a "special vocabulary".
* Beatrice Alex et al., [*Estimating and rating the quality of optically character recognised text*](http://dl.acm.org/citation.cfm?id=2595214). Proceedings of the First International Conference on Digital Access to Textual Cultural Heritage. 2014.
  
  > *"While there has already been a lot of research on OCR post-correction and normalisation, little work has been done on computing text quality of OCRed text. Some OCR output contains character-based accuracy rates which can be very deceptive. An extensive study on the quality ranking of short OCRed text snippets in different language has been explored by Popat. The main difference to the work described in this paper is that Popat examined the ranking order of text extracts by determining average rank correlation of inter-, intra- and machine-ratings. In contrast, we report manual and automatic quality ratings of individual documents and are less concerned about their rank compared to other documents in the collection."*
  
  The described approach is a simple-but-effective dictionary based one.

The [Lace Greek OCR project](http://heml.mta.ca/lace) incorporates a ground-truth-free metric called *b-score;* this is based on [Federico Boschetti's "textevaluator" package](http://www.himeros.eu/), which uses dictionaries and language-specific rules to determine the likeley "Greekness" of a text. However, they filter out Latin and other languages before applying this. I wanted something that would give me accuracy for a wide variety of languages, with no pre-filtering. My initial thought was to extend this approach with a large multi-lingual dictionary set. However, I wondered: can we use the existing [`langid`](https://github.com/saffsd/langid.py) classifier to get an approximation of OCR quality? [^entropy]

[^entropy]: If you're jumping up and down in your seat, raising your hand, begging to shout *"just use [entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory)) you idiots!"*, that thought occurred to me as well. The problem with this is that "OCR garbage" can be regular and repeating in the same way that human languages are; consider an OCR engine which outputs "/0I<au" consistently for every instance of the word "token".
    
    ![Entropy vs. Garbageness](https://docs.google.com/spreadsheets/d/1Hax7-ABq0KARS7GtSeTl75rkfUgYjVC791nptPSaPp0/pubchart?oid=49622873&format=image)

## Our Method

By first running `langid` classification against both the ABBYY OCR and my OCR, I could generate a shortlist of files where the overall `langid` classification didn't match; these are files where we likely have a significantly different OCR result from what's already available. Then, using `langid --line` on "bad OCR" files I could start to identify the patterns that occur in that output that strike me as "bad OCR" (the `langid` output is combined with the corresponding text line with `paste`):

<script src="https://gist.github.com/ryanfb/ec29a0b347334a948a97.js"></script>

After looking at a variety of files, I decided a good general rule for "bad OCR" was "blocks" of text with an average score > -100, separated by "blank" lines (score > 0). I then wrapped this up into a short script. Running it across my set of OCR texts revealed that this had the same problem I ran into before, that the `langid` confidence score is influenced by input length, so it needs to be normalized. After dividing each line's score by the number of characters in the line, it seemed like normalized scores between 0 and -1 were likely to be "garbage".

Here's the final version of the Ruby script I came up with for this process:

<script src="https://gist.github.com/ryanfb/3c97417da5ff3ca9c2e1.js"></script>

We can then run this processing across the set of language mismatch files to see [the "worst" OCR](https://gist.github.com/11d9aacfb95bc4ecbe5b), and compare to [our OCR](https://gist.github.com/c2dc8683e50bb924ae99) to see [what the improvement is](https://gist.github.com/ryanfb/8ab11c2078509d602ebc). Of course, we can tweak our thresholds for average score and block size, but I think this performs pretty well for most cases where I've looked at the output (though it may perform poorly for texts which frequently mix languages on the same line).

The advantage of this approach is that it uses the pre-trained statistical language models in [`langid`](https://github.com/saffsd/langid.py), enabling easy re-use of this metric (and easy training on your own corpus if the pre-trained models are insufficient).

I'm pretty excited about the potential for this. If we have a repeatable, improvable OCR process, and a reliable ground-truth-free way to approximate accuracy, we can close the loop on a workflow for continuously prioritizing, reprocessing, and improving our OCR results.

### Footnotes:

[^underwood]: While writing this, I came across Ted Underwood's post "[The obvious thing we're lacking](http://tedunderwood.com/2012/04/26/the-obvious-thing-were-lacking/)" (which, funnily enough, suggests using a language model), which also has some other interesting suggestions for how such a quality metric could be used, e.g. in restricting search results. Ben Schmidt makes an excellent point about OCR metadata in the comments, which is something I've been thinking about with this process; I don't just want to keep the OCR text, I want to keep information about the *process* as well so I can know if re-processing is likely to give any improvement at all.
[^poco]: One could also imagine a quality metric which used the edit distance between raw OCR output and an unsupervised post-correction process (such as those in the simple rule-based heuristic approaches of Taghva et al., [*Automatic Removal of "Garbage Strings" in OCR Text: An Implementation*](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.81.8901) and Kulp et al., [*On Retrieving Legal Files: Shortening Documents and Weeding Out Garbage*](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.141.6212)).
