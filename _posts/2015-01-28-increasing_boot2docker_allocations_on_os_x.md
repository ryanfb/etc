---
title: Increasing boot2docker allocations on OS X
tags:
- docker
---

If you've [installed `docker`/`boot2docker` on Mac OS X](http://penandpants.com/2014/03/09/docker-via-homebrew/) and are getting `no space left on device` errors, you're likely to have already come across [some arcane instructions for increasing boot2docker volume size](https://docs.docker.com/articles/b2d_volume_resize/). If you've already tried [removing untagged docker images](http://jimhoskins.com/2013/07/27/remove-untagged-docker-images.html) and are still running into space issues (maybe you're just trying to build something really big?), you can actually very easily change your `boot2docker` volume size by editing [your `boot2docker` configuration](https://github.com/boot2docker/boot2docker-cli#configuration).

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
