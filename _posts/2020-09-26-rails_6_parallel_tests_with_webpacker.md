---
title: Rails 6 Parallel Tests with Webpacker
tags: rails
---
I recently switched a project over to using [Rails 6's built-in parallel tests](https://rubyinrails.com/2019/03/27/rails-6-parallel-tests/), by setting `parallelize(workers: :number_of_processors)` in `tests/test_helper.rb`

While this seemed to work fine locally, tests on CircleCI would randomly fail with multiple errors like the following:

		Webpacker can't find application.js in /home/circleci/repo/public/packs-test/manifest.json. Possible causes:
		1. You want to set webpacker.yml value of compile to true for your environment
			 unless you are using the `webpack -w` or the webpack-dev-server.
		2. webpack has not yet re-run to reflect updates.
		3. You have misconfigured Webpacker's config/webpacker.yml file.
		4. Your webpack configuration is not creating a manifest.
		Your manifest contains:
		{
		}

Ultimately, this seemed to be the result of a race condition when using the default Rails webpacker test environment configuration, which compiles packs on request.

I solved this by editing my `config/webpacker.yml` to put the `test` environment block below `production`, defining `production` as a YAML alias, and inheriting from it for the `test` environment, so that assets for test are precompiled once:

{% highlight yml %}
production: &production
  <<: *default

  # Production depends on precompilation of packs prior to booting for performance.
  compile: false

  # Extract and emit a css file
  extract_css: true

  # Cache manifest.json for performance
  cache_manifest: true

test:
  <<: *production

  # Compile test packs to a separate directory
  public_output_path: packs-test
{% endhighlight %}

Note that this means you'll need to run e.g. `RAILS_ENV=test bundle exec rails assets:precompile` before running your tests. I added the following to my `Rakefile` so that for local development, the default task (run when I just run `rake`) will precompile assets and then run tests:

		Rake::Task["default"].clear

		task :default do
			Rake::Task["assets:precompile"].invoke
			Rake::Task["test"].invoke
		end
