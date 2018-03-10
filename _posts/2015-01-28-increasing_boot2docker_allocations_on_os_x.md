---
title: Increasing boot2docker allocations on OS X
tags:
- docker
---

If you've [installed `docker`/`boot2docker` on Mac OS X](http://penandpants.com/2014/03/09/docker-via-homebrew/) and are getting `no space left on device` errors, you're likely to have already come across [some arcane instructions for increasing boot2docker volume size](https://web.archive.org/web/20151007203105/https://docs.docker.com/articles/b2d_volume_resize/). If you've already tried [removing untagged docker images](http://jimhoskins.com/2013/07/27/remove-untagged-docker-images.html) and are still running into space issues (maybe you're just trying to build something really big?), you can actually very easily change your `boot2docker` volume size by editing [your `boot2docker` configuration](https://github.com/boot2docker/boot2docker-cli#configuration).[^docker-machine] [^docker-mac]

Add the following line(s) to `~/.boot2docker/profile` (creating it if it's not already there):

    # Disk image size in MB
    DiskSize = 100000

This would give you a `boot2docker` VM with ~100GB of disk.

If you'd also like to run memory-intensive jobs with `docker` (you can change the memory limit of an individual `docker run` command with the `-m` flag), you can also add a line like:

    Memory = 8192

To give you a `boot2docker` VM with 8GB of memory, for example.

In order for these changes to take effect, you need to destroy your `boot2docker` VM and recreate it:

### ⚠︎ WARNING: THIS WILL DELETE ANY AND ALL LOCAL DOCKER CONTAINERS, IMAGES, AND LAYERS YOU HAVE NOT PUSHED ⚠︎

    boot2docker stop
    boot2docker destroy
    boot2docker init
    boot2docker start

Verify changes with `boot2docker config` or by ssh'ing into the `boot2docker` VM with `boot2docker ssh` and using e.g. `df -h` or `cat /proc/meminfo`.

### Footnotes:

[^docker-machine]: With the release of [`docker-machine`](https://docs.docker.com/machine/), that's probably how you're running `docker` under OS X now and these instructions no longer apply. However, if you were previously running `boot2docker` and follow [the `docker-machine` migration instructions](https://docs.docker.com/machine/migrate-to-machine/), any changes you made to `boot2docker` disk and memory sizes should carry over. With the `docker-machine` VirtualBox driver, you should be able to use `--virtualbox-disk-size` and `--virtualbox-memory` as arguments to `docker-machine create -d virtualbox`; presumably, you can do the same `stop`/`rm`/`create`/`start` cycle around this.
[^docker-mac]: With the release of [Docker for Mac](https://docs.docker.com/engine/installation/mac/#/docker-for-mac), the method for resizing the available disk space for containers/images has changed yet again. Apparently Docker for Mac defaults to a 64GB sparse disk image. The following instructions may work for resizing it: <https://forums.docker.com/t/consistently-out-of-disk-space-in-docker-beta/9438/46>
