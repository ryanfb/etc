---
title: Last Modified Dates for GitHub Pages Jekyll Posts
---

If you're hosting a blog on GitHub Pages, sometimes you wish you could include a "last modified" snippet on posts which you've revisited, updated, or modified after the initial publication. Sure, there's a [`jekyll-last-modified-at`](https://github.com/gjtorikian/jekyll-last-modified-at) plugin, but it's not part of the [GitHub Pages plugin whitelist](https://github.com/github/pages-gem/blob/master/lib/github-pages/plugins.rb), so you would have to locally build your site into HTML on each commit for GitHub Pages to statically serve pages with a baked-in "last modified" time. You could also include e.g. a `last_modified` variable in your [YAML Front Matter](https://jekyllrb.com/docs/front-matter/) which you manually update, but if you're trying to add it to a site which has a lot of old posts, this might be somewhat error-prone and tedious.

For this blog, I decided to add a small bit of JavaScript to my default layout which I call on page load, which uses the GitHub API to fetch the latest commit for the current page, compare it to the original publication date, and add it to the page if they differ:

<script src="https://gist.github.com/ryanfb/6ffdb5dc3f338f553711a452d2a4136b.js"></script>

([Full code here](https://github.com/ryanfb/etc/blob/4d24f757183e0fff83d95e42131f04124dab8896/_layouts/default.html#L34-L47))

This uses the [`jekyll-github-metadata`](https://github.com/jekyll/github-metadata) plugin to get the correct owner and repository. I also use [Polyfill.io](https://polyfill.io/v3/) to add support for `fetch` to older browsers.

Note that it's important to put this JavaScript somewhere where `page.path` will be expanded correctly, or alternately you could pass it in as a JS variable if you want to get fancy.
