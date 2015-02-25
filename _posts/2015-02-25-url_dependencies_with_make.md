---
title: URL dependencies with Make
---

Mike Bostock's excellent post [*Why Use Make*](http://bost.ocks.org/mike/make/) gives a compelling case for using Make (or another build system) for reproducible workflows. In it, he notes:

 > You can approximate URL dependencies by checking the Last-Modified header via `curl -I`.

However, I've never really found this straightforward in Make.[^maven] Often, I have huge files that I only want to download and reprocess if they've changed. There's not really an elegant way to do this in a single Make recipe that I've seen.

Searching around led me to [this post on using `curl -z`](http://blog.yjl.im/2012/03/downloading-only-when-modified-using.html) to only fetch files if they've been modified. But once I started testing this, I noticed many servers don't set Last-Modified headers.[^docker]

Looking into it further, I found that lots of CDN's and modern web servers when serving up large dynamic files are actually pretty likely to set an [ETag header](https://en.wikipedia.org/wiki/HTTP_ETag) in the response. So a more reliable strategy seemed to me to be to try ETag first, Last-Modified second, and Content-Length last.[^content-length]

[^content-length]: I eventually abandoned the idea of using Content-Length as it doesn't really give you a genuine clue as to whether the content has changed without retrieving the whole file; for a plain text file the same content length might indicate that the files are *likely* to be similar, but you can't know for sure without downloading the whole file and checking. 

The next problem is deploying this strategy in Make. What I initially thought was using a monolithic phony download target would work:

 > <blockquote class="twitter-tweet" lang="en"><p>Best idea I can come up with is a phony download target with curl -z or wget -N <a href="http://t.co/XWE94zn0ue">http://t.co/XWE94zn0ue</a> <a href="http://t.co/tv4XiNM5Fv">http://t.co/tv4XiNM5Fv</a></p>&mdash; Ryan Baumann (@ryanfb) <a href="https://twitter.com/ryanfb/status/568808528116355072">February 20, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

After a probably disproportionate amount of trial and error, here's what I came up with in practice:

<script src="https://gist.github.com/ryanfb/763eb507522fb7ed9c96.js"></script>

Here `download_url` takes the URL and output file as arguments, and downloads both the file and HTTP headers on the first call. On subsequent calls, it will check the headers for matching ETags,[^if-none-match] conditionally falling back to `curl -z` with the date of the last response if there's no ETags or an ETag mismatch. The `download` rule is our phony monolithic download rule that loops through downloading all our URLs. Making our real targets `%.xlsx` and `%.xlsx.header.txt` depend on this phony target means it gets called every time (which is what we want), but the processing which depends on them (using Gnumeric `ssconvert` to convert to CSV) will only trigger if the real target is updated. I also found I had to mark these real targets as `.PRECIOUS` to avoid Make automatically deleting them and triggering the build every time. You can see the results of multiple invocations [here](https://gist.github.com/ryanfb/568bbca3af09f64b5fd7).

Hopefully this approach is robust and generic enough to be reusable in a variety of different situations.

### Footnotes:

[^docker]: This is a problem which also plagues [Docker's caching strategy for `ADD` commands](https://github.com/docker/docker/issues/3672).
[^maven]: Some build systems, like Maven, have more robust support for artifacts, repositories, dependencies, etc. But then you have to put all that in a repository. I want to depend directly against URLs. More importantly, I want to depend against other people's URLs which I don't control.
[^if-none-match]: In my testing, many servers that had ETag headers in the response did not actually correctly implement If-None-Match for requests. So string matching, while hacky, works for a wider variety of URLs.
