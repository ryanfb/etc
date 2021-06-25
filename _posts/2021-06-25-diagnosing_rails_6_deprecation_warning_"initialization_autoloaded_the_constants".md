---
title: Diagnosing Rails 6 Deprecation Warning "Initialization autoloaded the constants"
tags: rails
---
If you've upgraded an app to [Rails 6 with the new Zeitwerk autoloading mode](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html), you may have encountered a deprecation warning like the following, particularly when you run your test suite:

```
DEPRECATION WARNING: Initialization autoloaded the constants ApplicationHelper, FontAwesome5, FontAwesome5::Rails, FontAwesome5::Rails::IconHelper, DeviseHelper, and ApplicationController.
```

The reason you may notice this specifically in your test environment instead of others is because the test environment is usually configured to log output to standard error.

Diagnosing this can be a little confusing, and I ran across all sorts of dead ends and wrong suggestions for fixing it. What actually helped was [this StackOverflow answer](https://stackoverflow.com/a/66427161), which suggests putting the line `pp caller_locations` at the top of a file that defines one of the constants you get warned about (in my example, I put this at the top of `app/helpers/application_helper.rb`). After doing so, you can quickly check with `bin/rails zeitwerk:check RAILS_ENV=test` to look at the backtrace *before* the message "`Hold on, I am eager loading the application.`" (you'll likely also have a backtrace *after* this message as well, but you're interested in the first backtrace because that's the backtrace from autoloading instead of eager loading).

You'll need to work your way through your particular backtrace to see how the constant is getting loaded - pay particular attention to anything that's coming from files inside your `config` or `config/initializers` paths.

In my case, these constants were being autoloaded because of [a line in an initializer which was defining a custom class which inherited from `ApplicationController`](https://gorails.com/episodes/devise-hotwire-turbo), causing the rest of the constants to be autoloaded. After moving that custom class definition into its own file in `app/controllers`, I tested again by removing my `pp caller_locations` line and running `bin/rails zeitwerk:check RAILS_ENV=test`. All good!

Again, what you specifically need to change or move will depend on how your constants happen to be getting loaded and what you need to change inside your Rails app's initialization process.
