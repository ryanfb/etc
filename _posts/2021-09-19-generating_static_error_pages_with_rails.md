---
title: Generating Static Error Pages with Rails
tags: rails
---
For [PodQueue](https://podqueue.fm), I wanted to generate static error pages that used the same Rails layout and branding as the main site, and while there are many approaches floating around for this, none quite worked exactly the way I wanted them to (or at all) with Rails 6 and Heroku.

The most promising approach I found was [this one by Ryan Schultz](https://blog.grio.com/2013/07/generating-static-pages-with-rails.html), however, it was written in 2013 and I had issues with getting the `ActionDispatch::Integration::Session`-based page rendering it uses to work. It still forms the basis for my solution though, which is to add a new `rake app:static` task to generate the static pages.

So in my Rails app's `lib/tasks/app.rake` I have:

<script src="https://gist.github.com/ryanfb/c9a2f865583752ae63709cb6152b3807.js"></script>

You'll notice that a major difference here is that I'm using `ApplicationController::Renderer` to render the pages into static files, since this seems to be the preferred way of doing it now (specifying the hostname and HTTPS, just in case). There's also some extra work I'm doing at the end for the [Heroku-specific error pages](https://devcenter.heroku.com/articles/error-pages) `application-error.html` & `maintenance-mode.html`, which get pushed to an S3 bucket. Since the Heroku error pages also get served via an `<iframe>`, I use Nokogiri to rewrite relative asset paths into absolute URLs. (If you're not using Heroku, you can ignore all that.)

The "regular" error pages just get written out to the `public` directory and served normally. The `app:static` task is hooked onto asset precompilation so that it happens afterwards every time I run a deploy - this is done by using `enhance` in my main `Rakefile` like so:

```ruby
Rake::Task['assets:precompile'].enhance do
  Rake::Task['app:static'].invoke
end
```

You may have also noticed that I said I wanted to use the main application layout for my errors, but I'm using `layout/errors` in the task. This is because I also *do* need some error-page-specific logic while still inheriting from the main layout (in `app/views/layouts/errors.html.erb`):

<script src="https://gist.github.com/ryanfb/949b4fd8e27f095bd46dc37cb7237bb2.js"></script>

Setting `content_for :error_page` lets us tell from any other layout or view if we're inside the static error page rendering context, and the `:stylesheets` content is used in the main layout to have error-page specific CSS.

One important thing for the way I use this is that I also use [Devise](https://github.com/heartcombo/devise) for authentication and `ApplicationController.renderer` doesn't have access to Devise's `Warden::Proxy` instance by default, so if you try to use any Devise methods like `user_signed_in?` or `current_user`, you'll get the exception:

    Devise could not find the `Warden::Proxy` instance on your request environment

So for any layout/view path triggered by our static error pages, we need to guard any Devise calls with a check on `content_for?(:error_page)`, e.g. `<% if (!content_for?(:error_page)) && user_signed_in? %>`.

I'm also using the [`high_voltage` gem](https://github.com/thoughtbot/high_voltage) to handle my error pages, but as long as you have a route for your error pages you should still be able to use this technique. Since the error pages use compiled asset slugs that will change constantly, I don't keep the generated pages in version control.

Thanks for reading, and I hope this approach helps you navigate the confusing landscape of Rails static error pages!
