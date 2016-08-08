---
title: Git strategies for Docker
tags:
- docker
---

There are a few different strategies for getting your Git source code into a [Docker](https://www.docker.com/) build. Many of these have different ways of interacting with Docker's caching mechanisms, and may be more or less appropriately suited to your project and how you intend to use Docker. Perhaps surprisingly, I haven't been able to locate an overview of these strategies collected in one place, and it's not covered in the [Dockerfile best practices guide](https://docs.docker.com/articles/dockerfile_best-practices/).

Here are the strategies I've come across so far:

 * [`RUN git clone`](#run-git-clone)
 * [`RUN curl` or `ADD` a tag/commit tarball URL](#run-curl-or-add-a-tagcommit-tarball-url)
 * [Git submodules inside `Dockerfile` repository](#git-submodules-inside-dockerfile-repository)
 * [`Dockerfile` inside git repository](#dockerfile-inside-git-repository)
 * [Volume mapping](#volume-mapping)

## `RUN git clone`

If you're like me, this is the approach that first springs to mind when you see the commands available to you in a `Dockerfile`. The trouble with this is that it can interact in several unintuitive ways with Docker's build caching mechanisms. For example, if you make an update to your git repository, and then re-run the `docker build` which has a `RUN git clone` command, you may or may not get the new commit(s) depending on if the preceding `Dockerfile` commands have invalidated the cache. 

One way to get around this is to use `docker build --no-cache`, but then if there are any time-intensive commands preceding the `clone` they'll have to run again too.

Another issue is that you (or someone you've distributed your `Dockerfile` to) may unexpectedly come back to a broken build later on when the upstream git repository updates.

A two-birds-one-stone approach to this while still using `RUN git clone` is to put it on one line[^oneline] with a specific revision checkout, e.g.:

    RUN git clone https://github.com/example/example.git && cd example && git checkout 0123abcdef

Then updating the revision to check out in the `Dockerfile` will invalidate the cache at that line and cause the `clone`/`checkout` to run.

One possible drawback to this approach in general is that you have to have `git` installed in your container.

[^oneline]: The reason to put this on one line is the same reason [you shouldn't put `RUN apt-get update` on a single line](https://docs.docker.com/articles/dockerfile_best-practices/#run-https-docs-docker-com-reference-builder-run). Consider instead the form:

          RUN git clone https://github.com/example/example.git
          RUN cd example && git checkout 0123abcdef

    Here, if you update the revision, the `clone` command will still use the cache while the `checkout` won't, and you may try to check out a revision which isn't in the cache.

## `RUN curl` or `ADD` a tag/commit tarball URL

This avoids having to have `git` installed in your container environment, and can benefit from being explicit about when the cache will break (i.e. if the tag/revision is part of the URL, that URL change will bust the cache). Note that if you use [the `Dockerfile` `ADD` command](https://docs.docker.com/reference/builder/#add) to copy from a remote URL, the file will be downloaded every time you run the build, and the HTTP `Last-Modified` header will also be used to invalidate the cache.

You can see this approach used in [the golang `Dockerfile`](https://github.com/docker-library/golang/blob/1a422afd7db928a821e97906ed27ed606e2f072a/1.3/Dockerfile).

## Git submodules inside `Dockerfile` repository

If you keep your `Dockerfile` and Docker build in a separate repository from your source code, or your Docker build requires multiple source repositories, using [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (or [git subtrees](http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/)) in this repository may be a valid way to get your source repos into your build context. This avoids some concerns with Docker caching and upstream updating, as you lock the upstream revision in your submodule/subtree specification. Updating them will break your Docker cache as it changes the build context.

Note that this only gets the files into your Docker build context, you still need to use [`ADD` commands in your `Dockerfile`](https://docs.docker.com/reference/builder/#add) to copy those paths to where you expect them in the container.

I use this approach in my [Docker for Latin OCR training](https://github.com/ryanfb/tesseract_latinocr_docker) repository.

## `Dockerfile` inside git repository

Here, you just have your `Dockerfile` in the same git repository alongside the code you want to build/test/deploy, so it automatically gets sent as part of the build context, so you can e.g. `ADD . /project` to copy the context into the container. The advantage to this is that you can test changes without having to potentially commit/push them to get them into a test `docker build`; the disadvantage is that every time you modify any files in your working directory it will invalidate the cache at the `ADD` command. Sending the build context for a large source/data directory can also be time-consuming. So if you use this approach, you may also want to make judicious use of [the `.dockerignore` file](https://docs.docker.com/reference/builder/#dockerignore-file), including doing things like ignoring everything in your `.gitignore` and possibly the `.git` directory itself. You may also want to ignore the `Dockerfile` in your `.dockerignore`, as you are unlikely to be using the `Dockerfile` inside the container, and otherwise it will invalidate the cache at the `ADD` line every time you change your `Dockerfile`.

## Volume mapping

If you're using Docker to set up a dev/test environment that you want to share among a wide variety of source repos on your host machine, [mounting a host directory as a data volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume) may be a viable strategy. This gives you the ability to specify which directories you want to include at `docker run`-time, and avoids concerns about `docker build` caching, but none of this will be shared among other users of your `Dockerfile` or container image.


### Footnotes
