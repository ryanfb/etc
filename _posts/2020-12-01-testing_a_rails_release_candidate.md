---
title: Testing a Rails Release Candidate
tags: rails
---
So, you want to kick the tires on a new Rails release candidate to check out new features, give feedback, and see what the upgrade will be like for your app?

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Rails 6.1 RC1 was just released full of new great stuff for you to check them out. Horizontal Sharding, Multi-DB Improvements, Strict Loading, Destroy Associations in Background, Error Objects, and more! <a href="https://t.co/8PJpO4Htue">https://t.co/8PJpO4Htue</a></p>&mdash; Ruby on Rails (@rails) <a href="https://twitter.com/rails/status/1323380514598887426?ref_src=twsrc%5Etfw">November 2, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

The only problem is, release candidates don't get a gem "cut" for them on RubyGems, so you can't just bump the version in your `Gemfile`. Instead, what you need to do is this:

1. Switch to a new branch (optional, but recommended)
2. Change the `gem 'rails'` line in your `Gemfile` to use the Rails Git repository and the release candidate tag you want:

        gem 'rails', git: 'https://github.com/rails/rails.git', tag: 'v6.1.0.rc1'

3. Run `bundle`
4. Run `bundle exec rails app:update` and follow the prompts
5. Done! Play around, see what breaks, file any relevant bug reports so they get fixed in the next RC or final release. Check the [Edge "Upgrading Ruby on Rails" guide](https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html) for notes on the specific upgrade you're testing.
