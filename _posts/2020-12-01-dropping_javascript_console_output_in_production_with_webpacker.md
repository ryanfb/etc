---
title: Dropping JavaScript Console Output in Production with Webpacker
tags: rails
---
Want to avoid embarassing JavaScript console output in a production Rails app that's using Webpacker?

It's easy! Just pass `drop_console = true` into your Webpack's "Terser" configuration (what Webpack uses for minification), and console output should be stripped from all your Webpacker assets.

As it turns out, other people have also found this confusing, and [a helpful GitHub issue comment has the solution](https://github.com/rails/webpacker/issues/2131#issuecomment-528128380):

In your `config/webpack/production.js`, after the `const environment` line simply add the following:

{% highlight javascript %}
environment.config.optimization.minimizer.find(m => m.constructor.name === 'TerserPlugin').options.terserOptions.compress.drop_console = true
{% endhighlight %}

Commit, reload, and enjoy the amazing freedom of using `console.log` in development without worrying about it leaking into production.
