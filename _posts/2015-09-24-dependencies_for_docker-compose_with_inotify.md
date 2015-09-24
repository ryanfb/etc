---
title: Dependencies for docker-compose with inotify
tags: docker
---

If you're using [Docker Compose](https://docs.docker.com/compose/) to orchestrate multiple [Docker](https://www.docker.com/) containers, you may run into instances where you want to delay starting one container until another container finishes doing something (say, database initialization).[^dockerissues]

[^dockerissues]: See also:
   
    * [docker/compose#235: Order of containers starting up?](https://github.com/docker/compose/issues/235)
    * [docker/compose#374: Is there a way to delay container startup to support dependant services with a longer startup time](https://github.com/docker/compose/issues/374)
    * [docker/compose#686: Allow dependencies to be specified explicitly with `depends_on`](https://github.com/docker/compose/pull/686)
    * [docker/compose#935: volumes_from not running dependent container(?)](https://github.com/docker/compose/issues/935)

There are some existing tools like [`docker-wait`](https://github.com/aanand/docker-wait) for waiting on TCP connections, but if you want to wait on a container that's building something in a shared volume instead of providing a service, this may not be a great match for what you want to do.

A simple workaround I've found for this is to use `volumes_from` in `docker-compose.yml` and the [`inotifywait`](http://linux.die.net/man/1/inotifywait) tool to block execution in one container based on a [file semaphore](https://en.wikipedia.org/wiki/Semaphore_(programming)) written by another container.

Here's the directory structure for a minimal example ([GitHub repo](https://github.com/ryanfb/docker-compose-inotify-example)), where we want to wait until `docker-container-2` has finished doing something before starting `docker-container-1`:

    +-- docker-compose.yml
    +-- docker-container-1
    |   +-- Dockerfile
    +-- docker-container-2
        +-- Dockerfile

Our `docker-compose.yml` looks like this, pulling a volume from container 2 into container 1 with `volumes_from`:

<script src="https://gist-it.appspot.com/http://github.com/ryanfb/docker-compose-inotify-example/blob/master/docker-compose.yml"></script>

Our `Dockerfile` for container 2 contains:

<script src="https://gist-it.appspot.com/http://github.com/ryanfb/docker-compose-inotify-example/blob/master/docker-container-2/Dockerfile"></script>

And the `Dockerfile` for container 1 has:

<script src="https://gist-it.appspot.com/http://github.com/ryanfb/docker-compose-inotify-example/blob/master/docker-container-1/Dockerfile"></script>

When we run `docker-compose up --force-recreate` in this directory we get the output:

<script src="https://gist.github.com/ryanfb/a297031fb834ce59f520.js"></script>

Note that there are some catches to this that you may need to work around, depending on how you plan to use this pattern. For one, it depends on the container being Linux-based and providing `inotify`, and `inotify-tools` being installed. For another, if you noticed the `sleep` command in `docker-container-2`, a fast process in one container could race the `inotify` watches being set up in another. So if you anticipate that being a potential issue for how you're using this you'll need to add some additional logic for it (e.g., only calling `inotifywait` if the file semapthore doesn't already exist). You'll also notice the `tail -f /dev/null` in `docker-container-2` to prevent its `exit` causing all the other containers in docker-compose to stop (see [this related pull request for `docker-compose`, which should be in the 1.5 release](https://github.com/docker/compose/pull/1754)).

### Footnotes
