---
title: Using Rapporteur with source versions on Heroku
tags: rails
---
[Rapporteur](https://github.com/envylabs/rapporteur) is a nice simple gem for adding a status endpoint to your Rails app. It also has support for including the source version (e.g. `git` commit) in the status response. While the docs suggest using `ENV["REVISION"]` for Heroku, I found that wasn't set automatically in my Heroku runtime stack.

The workaround I developed for [PodQueue](https://podqueue.fm) was to use [the `SOURCE_VERSION` environment variable set in the Heroku "build" stage](https://devcenter.heroku.com/articles/buildpack-api) to automatically write out a file with the source revision which we can then load from the runtime.

First, I made a new `rake` task which will generate the revision file (in `lib/tasks/app.rake`):

```ruby
namespace :app do
  desc 'Generates .source_version'
  task source_version: :environment do
    if ENV['SOURCE_VERSION'].present?
      warn "Writing revision #{ENV['SOURCE_VERSION']} to .source_version"
      File.write(Rails.root.join('.source_version'), ENV['SOURCE_VERSION'])
    end
  end
end
```

Then, we hook our new `app:source_version` task onto the `assets:precompile` task automatically invoked by the Heroku Rails build by using `enhance` in our `Rakefile` (you'll need to hook this onto something else if your build doesn't use asset precompilation):

```ruby
Rake::Task['assets:precompile'].enhance do
  Rake::Task['app:source_version'].invoke
end
```

Finally, we configure Rapporteur to use the `.source_version` file we write out during the "build" stage (`config/initializers/rapporteur.rb`):

```ruby
if Rails.env.production? && File.exist?(Rails.root.join('.source_version'))
  Rapporteur::Revision.current = File.read(Rails.root.join('.source_version'))
end
```

Now, your next deploy should have the correct `git` revision in its status response, which you can use to do fun things like [automatically wait for a deploy to bubble through CI/CD into production](https://gist.github.com/ryanfb/675038152aeccbd2cdbe59b125acf65f).
