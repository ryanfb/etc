---
title: Archiving the AWOL Index
---

[The AWOL Index](http://isaw.nyu.edu/publications/awol-index/) is a new experimental project to extract structured data from [AWOL - The Ancient World Online](http://ancientworldonline.blogspot.com/), which has published links to material about the ancient world since 2009.

As a practical experiment, I thought it might be interesting to check which URLs in the index are already in web archives, and try to archive those which are not. To do this, I downloaded the AWOL index JSON, unzipped it, and extracted unique linked URLs with:

    find . -name '*.json' -exec grep '"url":' {} \; | \
    sed -e 's/^.*"url": "//' -e 's/".*$//' | \
    sort -u > urls-clean-uniq.txt

This gave me [52,020 unique URLs](https://gist.github.com/639e9366926c889b112f).

Initially, I thought it would be best to check if the URLs were in *any* web archive, rather than just one. To do this, I used the [mementoweb.org Time Travel API](http://timetravel.mementoweb.org/guide/api/) to hit the ["Find"](http://timetravel.mementoweb.org/about/#find) service to check URL availability in a wide range of archives. Unfortunately, this proved to be a relatively slow process.

In order to speed things up, I decided to try checking and using just one web archive: [the Internet Archive Wayback Machine](http://archive.org/web/). Using some hand-picked URLs that showed as "missing" from the truncated mementoweb.org process, I checked [the Wayback Machine Availability API](https://archive.org/help/wayback_api.php) to see what sort of results I got.

Interestingly, this lead to the realization that [certain URLs which show no availability in the JSON API](http://archive.org/wayback/available?url=http://ager2.voila.net/AGER10.pdf) [do show availability in the CDX API](http://web.archive.org/cdx/search/cdx?url=http://ager2.voila.net/AGER10.pdf). So, I decided to check URL availability using the relatively fast CDX API for the most accurate results:

    while read url; do \
      if [ -n "$(curl -s "http://web.archive.org/cdx/search/cdx?url=${url}")" ]; \
        then echo "$url" >> cdx-success.txt; \
        else echo "$url" >> cdx-failure.txt; \
      fi; \
    done < urls-clean-uniq.txt

After this process finished running, I had 34,832 URLs showing as already successfully archived (or about 67%). For the remainder, I wanted to submit them to the Wayback Machine for archiving, which I did with:

    while read url; do \
      echo "$url"; \
      curl -L -o/dev/null -s "http://web.archive.org/save/$url"; \
    done < cdx-failure.txt

So, any live, savable URLs which weren't already in the archive at the time this process was run should be added to it.

After this process finished, I did an initial pass at checking the submitted URLs for presence in the CDX index, and found 10,823 hits for the 17,188 URLs submitted (a 63% success rate). I also noticed that the CDX server can *occasionally* give false negatives as well (i.e. returns no results for something that's in the index), so I did another pass against the 6,365 "missing" URLs to try to see if they were actually available, which added only 5 URLs as false negatives from the initial run.

So, after running these processes it seemed the Wayback Machine now had at least one snapshot for 45,660 of our 52,020 URLs (about 88%). Spot-checking [the remaining 6,360 URLs](https://gist.github.com/5a903d473defe06ac995) showed that some returned no snapshots via *either* the [JSON](http://archive.org/wayback/available?url=http://tobias-lib.uni-tuebingen.de/frontdoor.php?source_opus=5744&la=de) or [CDX](http://web.archive.org/cdx/search/cdx?url=http://tobias-lib.uni-tuebingen.de/frontdoor.php?source_opus=5744&la=de) APIs but [show snapshots in the web interface](http://web.archive.org/web/*/http://tobias-lib.uni-tuebingen.de/frontdoor.php?source_opus=5744&la=de). This particular example [shows in the mementoweb.org API](http://timetravel.mementoweb.org/api/json/2015/http://tobias-lib.uni-tuebingen.de/frontdoor.php?source_opus=5744&la=de), so I decided to try checking the Wayback Memento API by hitting `http://web.archive.org/web/{URI-R}`:

    while read url; do echo $url; \
      if curl -s --fail -I "http://web.archive.org/web/$url"; \
        then echo $url >> memento-success.txt; \
      fi; \
    done < cdx-missing-combined.txt

This revealed that 4,606 of our 6,360 "missing" URLs were, in fact, successfully archived (so 50,266 of our 52,020 original URLs, or about 97%, now have at least one snapshot in the Wayback Machine). Looking at [the remaining 1,754 missing URLs](https://gist.github.com/309b5e9a483bd98345c2), we can triage these further and see what currently returns a "live" response code with:

    while read url; do \
      if curl -s --fail -L -I "$url" ; \
        then echo "$url" >> cdx-missing-live-success.txt; \
        else echo "$url" >> cdx-missing-live-failure.txt; \
      fi; \
    done < cdx-memento-missing.txt

Giving us [431 URLs with no snapshots that currently return an HTTP error](https://gist.github.com/d73a99e2d1e2b611622a) (so less than 1% of our total URL count).

I plan on doing one more archive run for [the remaining 1,323 missing URLs](https://gist.github.com/8629e20583481082bd00), just in case some temporary server issues cropped up during the initial run.

Going forward, it might be helpful to automate this process to check and archive new URLs in the AWOL Index on a periodic basis. There are probably much more interesting things that can be done with mining and analyzing the AWOL Index, but the foundation of some of these activities will rely on the simple availability of the linked content.
