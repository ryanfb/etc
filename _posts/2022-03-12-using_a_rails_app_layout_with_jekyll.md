---
title: "Using a Rails App Layout with Jekyll"
---
There's a number of different strategies you can use to host a blog for your app or company, and for [PodQueue](https://podqueue.fm) I went with the tried-and-true "static Jekyll site on a blog subdomain" approach. There are tradeoffs to every approach, and one here is that I initially ran the blog with a generic Jekyll theme just to have something up and running. I wanted the blog to have the same styling and layout as the main site with just a few blog-specific tweaks, so here's how I accomplished that.

The main PodQueue website runs on Rails, and has an app-wide layout used for most pages. So to generate my Jekyll layout, I have a single page/endpoint in the Rails app that uses that layout with Jekyll's <code>&lbrace;&lbrace; content &rbrace;&rbrace;</code> templating tag as the only content. I can then just download that `/layout` endpoint as the HTML I'm going to use for my Jekyll layout (`_layouts/default.html`).

As I mentioned, there are a few blog-specific tweaks I want to add to the Rails-generated layout before using it as my Jekyll layout (e.g. YAML front matter, changing "PodQueue" to "PodQueue Blog", using Jekyll's <code>&lbrace;&lbrace; page.title &rbrace;&rbrace;</code>, etc.). I made these changes *once*, then generated a patch file with:

    diff -u layout default.html > layout.patch

Now, when I want to update the Jekyll layout from the Rails layout, I can simply re-download the layout, apply the patch, and overwrite my `default.html`.

Just for good measure, [I've wrapped all these steps into a script](https://github.com/podqueue/blog.podqueue.fm/blob/main/script/layout.sh) that will automatically update my Jekyll layout from my Rails layout (as well as refresh the patch so that drift over time doesn't result in patch rejection). Eventually, I can automate this to trigger whenever a successful deploy happens, or just on a periodic basis. You may especially want to do this if you're referring to production assets (JS/CSS/etc.) which will change with each deploy and become unavailable (I'm using a CDN configuration that allows old assets to stick around, so it's not quite as crucial). You'll also want to check that any relative URLs in your layout are correct, and change them to absolute URLs if necessary in your initial patch configuration.
