---
title: Archiving Jekyll Websites with Sitemaps
---
If you run a [Jekyll](https://jekyllrb.com/) blog (like this one!), you might be interested in having your blog posts saved in a web archive like the [Internet Archive Wayback Machine](http://web.archive.org/). In this post, I'll show you how you can use an auto-generated sitemap to get a list of all URLs on your Jekyll blog, then feed those URLs to a web archiving process.

Adding a [sitemap](https://en.wikipedia.org/wiki/Site_map) to your Jekyll blog or website is easy. Assuming your configuration is relatively straightforward, using the [`jekyll-sitemap` plugin](https://github.com/jekyll/jekyll-sitemap) can be as simple as [adding a line to your site's `_config.yml` if you're using GitHub Pages](https://help.github.com/articles/sitemaps-for-github-pages/). Once you've done that, test that the URLs you're generating in the resulting `sitemap.xml` are valid and you should be good to go. Generating a sitemap also has SEO benefits, as it allows search engines to crawl your site more easily.[^google]

Once you have a working sitemap, you can get the URLs back out of it with `sitemap-urls`: [^bash]

    curl https://mysite.github.io/sitemap.xml | sitemap-urls

Now we can use that list of URLs to drive our archiving process:

    curl https://mysite.github.io/sitemap.xml | sitemap-urls | while read url; do \
      curl -g --fail --retry 3 -L -o/dev/null -s "http://web.archive.org/save/$url"; \
    done

This should tell the Wayback Machine to save all the URLs from the sitemap. Wrap this up in a script you can put in a periodic `cron` job and you can rest easy knowing that your pages are being regularly archived. A similar process should work for archiving any (non-Jekyll) website that provides a sitemap.[^wordpress] You could also use the scripts from my [web-archive-triage](https://github.com/ryanfb/web-archive-triage) repository to do some more complicated things, such as only archiving pages that have no snapshot.

### Footnotes:

[^google]: You can also submit your sitemaps to Google and check up on them through the [Google Search Console](https://www.google.com/webmasters/tools/home?hl=en) (formerly Webmaster Tools).
[^bash]: [This more complicated `bash` process](http://infoheap.com/bash-extract-urls-from-xml-sitemap/) may work if you don't have `node`/`npm` installed.
[^wordpress]: If you run a WordPress blog, you may also be interested in the [Archiver plugin](https://wptavern.com/new-archiver-wordpress-plugin-auto-generates-wayback-machine-snapshots).
