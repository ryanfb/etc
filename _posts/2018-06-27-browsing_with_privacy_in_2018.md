---
title: Browsing With Privacy in 2018
---
This blog post is just a short note on how I've switched my web browsing habits in an attempt to regain some control over privacy. The biggest switch was switching from Chrome to Firefox. Why? Because Firefox offers a privacy innovation which Chrome hasn't duplicated yet: browser containers. Used properly, this makes it harder for sites to track your activity on other sites. The extensions I use to get the most privacy out of Firefox are:

* [Multi-Account Containers](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/) - this allows you to separate browsing activity and cookies into different kinds of containers. You can assign specific websites to always open in a specific container, or to prompt you to open in a specific container. For example, I have a "Google" container which is the only container I use to sign in to Google. I have "inbox.google.com" and "calendar.google.com" set to always open in the Google container, but other Google services (such as Maps and YouTube) set only to prompt, so that I can choose whether or not I want something associated directly with my account history.
* [Facebook Container](https://addons.mozilla.org/en-US/firefox/addon/facebook-container/) - this is Multi-Account containers, specifically pre-configured to always open Facebook in its own container and wipe Facebook cookies from other containers.
* [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) - privacy protection and ad blocking.
* [Privacy Badger](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/) - from the EFF, which adds additional tracker and privacy protection.
* [First Party Isolation](https://addons.mozilla.org/en-US/firefox/addon/first-party-isolation/) - "Think of it as blocking Third-party cookies, but more exhaustively". Some sites will break with this enabled, so you may need to toggle it off as needed.
* [Tracking Token Stripper](https://addons.mozilla.org/en-US/firefox/addon/utm-tracking-token-stripper/) - removes click tracking identifiers from URL query strings.

In addition to this, I've also switched to using [DuckDuckGo](https://duckduckgo.com/) as my default search engine. For cases where I feel like I still need to do a search in Google, I use the `!g` [bang shortcut](https://duckduckgo.com/bang). For extra ad-blocking overkill, I've also configured a [Pi-hole](https://pi-hole.net/) DNS server for home use.
