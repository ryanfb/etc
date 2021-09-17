---
title: "Removing \"?ref=producthunt\" from your search results"
tags: rails
---
After launching [PodQueue](https://podqueue.fm), I submitted it to many of the usual product launch sites, including [Product Hunt](https://www.producthunt.com/posts/podqueue). In submitting PodQueue, I set the webpage to be "`https://podqueue.fm`", which Product Hunt turns into the outbound tracking link "`https://www.producthunt.com/r/f179c9b85faf16`", which in turn resolves to "`https://podqueue.fm/?ref=producthunt`". Fair enough, I could do some click/conversion tracking from that if I wanted to, although I didn't ask for it and there's no way to turn it off.

Unfortunately, though, what started happening after this is that for various search engines, I now had two search results for the same page competing with each other, "`https://podqueue.fm`" (which I wanted people to see and click on) and "`https://podqueue.fm/?ref=producthunt`" (it's the same page but with a not-even-correct referrer now!).

I took a double-barrel approach to solving this, and while you may be able to fix it with just one or the other, I fixed it with both, and no longer see duplicated entries for my landing page in search results.

The first was to use an [HTTP 301 Moved Permanently redirect](https://en.wikipedia.org/wiki/HTTP_301) whenever a `ref` parameter is passed. Since PodQueue runs on Rails, I could do this with a line in the relevant controller action:

    redirect_to root_url, status: :moved_permanently and return if params['ref'].present?

Now, requesting "`https://podqueue.fm/?ref=producthunt`" will tell clients that they should *permanently redirect* to "`https://podqueue.fm`" instead.

The second technique was to introduce a metadata tag inside the `<head>` of the HTML returned at the root URL:

    <link rel="canonical" href="https://podqueue.fm">

This tells clients that parse the HTML that the *canonical representation* of this link is "`https://podqueue.fm`".

Note that you shouldn't hardcode this in your layout, since then every page will say that the canonical URL is the root URL - you should set it dynamically or conditionally depending on what you want to accomplish.

With both of these techniques deployed and in production, search engines now show just my preferred URL for my site instead of two duplicate entries!
