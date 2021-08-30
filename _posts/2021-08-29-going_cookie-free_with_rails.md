---
title: Going Cookie-Free With Rails
tags: rails
---
For [PodQueue](https://podqueue.fm), I wanted to be able to respect users' privacy by only even setting a first-party cookie when we absolutely had to. As it turns out, this can be a little confusing in Rails, since by default Rails wants to store the session as a first-party cookie on every response. It also uses this session data for things like [CSRF protection](https://en.wikipedia.org/wiki/Cross-site_request_forgery) on form submission, and for storing/displaying flash notifications, so if you want to do either of those things without cookies you'll probably need to do a little more work.

For my purposes, it was sufficient to disable the session cookie *unless* you were going to a page with [Devise](https://github.com/heartcombo/devise) (e.g. to sign up or log in, which will require a non-tracking cookie for CSRF protection) **or** are already signed in. I was able to accomplish this with the following lambda function in the app's `ApplicationController` (`app/controllers/application_controller.rb`):

```ruby
after_action lambda {
               request.session_options[:skip] = !(user_signed_in? || devise_controller?)
             }
```

You could also easily exempt other controllers as necessary, but this is an excellent way to both respect privacy **and** not have to display an annoying GDPR cookie notification!
