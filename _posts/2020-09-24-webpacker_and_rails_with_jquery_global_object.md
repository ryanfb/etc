---
title: Webpacker and Rails with jQuery Global Object 
tags: rails
---
If you're using Webpacker with Rails 6, you may have run into an issue trying to use jQuery in JavaScript from a global context. Usually this will show up in the console as something like "`$ is not defined`," particularly if you're trying to use jQuery from your `*.js.erb` views for [SJR (Server-generated JavaScript Responses)](https://adamsimpson.net/writing/ajax-and-rails) for AJAX.

I've come across a huge number of confusing and outdated answers for how to fix this, so I'm sharing what worked for me at the time of this writing (Rails 6.0.3.3, webpacker 5.2.1).

The best way seems to be to use [the `expose-loader` module](https://github.com/webpack-contrib/expose-loader) to expose jQuery from your webpack config. For me this meant running `yarn add expose-loader --dev` to install the module, then updating my `config/webpack/environment.js` to expose jQuery as `$` and `jQuery`:

{% highlight js %}
const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))

environment.loaders.append('jquery', {
  test: require.resolve('jquery'),
  loader: 'expose-loader',
  options: {
    exposes: ['$', 'jQuery']
  }
})

environment.splitChunks()

module.exports = environment
{% endhighlight %}

For me, the `environment.loader.append` block is the only new addition here; if you haven't already installed jQuery and aren't already loading `jquery` as a plugin, you may need to do that as well. Note that this should work with `expose-loader` 1.0.0—other solutions I found used a syntax that was incompatible with this version, and would result in the error:

    Expose Loader has been initialized using an options object that does not match the API schema.
     - options misses the property 'exposes'
