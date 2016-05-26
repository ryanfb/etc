---
title: Continuous Data Validation with Travis
---
"Continuous Integration" with automated unit tests is a widely accepted practice to try to ensure software quality. What about applying the same principle to ensure data quality? If you keep data in a version control system like Git, and already have (or can develop) an automated way to validate this data, you're almost all of the way there to automatically validating every commit to your data repository.

If your data repository is on GitHub, this is pretty easy to set up with [Travis CI](https://travis-ci.org/). This will also have the added benefit of automatically validating pull requests so you can see if they pass your data validation process before merging. Follow the [Getting Started](https://docs.travis-ci.com/user/getting-started/) guide for setting up Travis and adding your repository, then configure your `.travis.yml` file to run your data validation in the `script` step.[^html]

The main place I've been using this in practice is for [automated validation](https://travis-ci.org/papyri/idp.data) of [the Papyri.info data repository](https://github.com/papyri/idp.data). This validates all of the main XML files in the repository against their associated [RELAX NG](https://en.wikipedia.org/wiki/RELAX_NG) schemas using [Jing](http://www.thaiopensource.com/relaxng/jing.html):

<script src="https://gist-it.appspot.com/github/papyri/idp.data/blob/master/.travis.yml"></script>

I've also added a simple JSON validation with [JSON Lint](https://github.com/zaach/jsonlint) to my [`iiif-universe` repository](https://github.com/ryanfb/iiif-universe):

<script src="https://gist-it.appspot.com/github/ryanfb/iiif-universe/blob/gh-pages/.travis.yml"></script>

You can even do CSV validation with [`csvlint`](https://github.com/theodi/csvlint.rb) (schema optional):

<script src="https://gist-it.appspot.com/github/ryanfb/loeb-copyright/blob/master/.travis.yml"></script>

Hopefully these simple examples give you an idea of how to get started and apply the same pattern to your data repositories—even if you aren't using Travis, the same principle should work for other continuous integration solutions.

Of course, you could also go further than "just" schema validation or linting, and start adding assertions about the data content itself!

### Footnotes:

[^html]: You can also this approach to, for example, [automatically validate your statically-generated websites with `html-proofer`](http://jekyllrb.com/docs/continuous-integration/).
