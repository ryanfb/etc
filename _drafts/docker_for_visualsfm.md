---
title: Docker for VisualSFM
---

In [a previous post]({{ site.baseurl }}{% post_url 2014-10-22-drone_photogrammetry_workflow %}) I outlined a workflow for using [VisualSFM](http://ccwu.me/vsfm/) for photogrammetry. In this post, I'd like to highlight [some recent work I've done](https://github.com/ryanfb/docker_visualsfm) for creating an isolated, replicable VisualSFM environment using [Docker](https://www.docker.com/).

Using a Local Docker Host
-------------------------

First, follow the [Docker installation guide](https://docs.docker.com/installation/) for your platform (though on a Mac, you may prefer to follow [this Homebrew-based guide](http://penandpants.com/2014/03/09/docker-via-homebrew/)).

After you've set up `docker` and your shell's environment variables (using e.g. `$(boot2docker shellinit)`), run:

    docker run -i -t ryanfb/visualsfm /bin/bash

Which should download [my image from Docker Hub](https://registry.hub.docker.com/u/ryanfb/visualsfm/) and drop you into a shell with a `VisualSFM` command (as well as `youtube-dl`, and [`ffmpeg` replacement `avconv`](http://askubuntu.com/a/432585)).

Using an AWS GPU-Enabled Docker Host
------------------------------------

Because my VisualSFM image builds on [work by Traun Leyden](http://tleyden.github.io/blog/2014/10/25/docker-on-aws-gpu-ubuntu-14-dot-04-slash-cuda-6-dot-5/) to build [a CUDA-enabled Ubuntu install with Docker](https://registry.hub.docker.com/u/tleyden5iwx/ubuntu-cuda/), you can run it in a GPU-enabled environment to take advantage of [SiftGPU](http://cs.unc.edu/~ccwu/siftgpu/) during the SIFT feature recognition stage of VisualSFM processing (with no GPU/CUDA support detected, it will fall back to the CPU-based [VLFeat](http://www.vlfeat.org/) SIFT implementation).[^siftgpu]

This means you can also use [his instructions and AMI for building a CUDA-enabled AWS EC2 instance](http://tleyden.github.io/blog/2014/10/25/cuda-6-dot-5-on-aws-gpu-instance-running-ubuntu-14-dot-04/), and then run my VisualSFM image inside it.

To do this you'll need to:

 * [Launch an EC2 instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-instance_linux.html) with instance type `g2.2xlarge`, community AMI `ami-2cbf3e44`, and 20+ GB of storage
 * [Connect to your EC2 instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-connect-to-instance-linux.html)
 * Install `docker` inside your EC2 instance:
   * `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9`
   * `sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"`
   * `sudo apt-get update`
   * `sudo apt-get install lxc-docker`
 * Run a GPU-enabled VisualSFM docker image:
   * Build the CUDA samples and run `deviceQuery` inside your Docker host (this seems to be necessary to init the nvidia devices in `/dev`):
     * `cd ~/nvidia_installers`
     * `sudo ./cuda-samples-linux-6.5.14-18745345.run -noprompt -cudaprefix=/usr/local/cuda-6.5/`
     * `cd /usr/local/cuda/samples/1_Utilities/deviceQuery`
     * `sudo make`
     * `./deviceQuery`
   * Find your nvidia devices with: `ls -la /dev | grep nvidia`
   * Set these as `--device` arguments in a variable you'll pass to the `docker run` command:
     * `export DOCKER_NVIDIA_DEVICES="--device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm"`
     * `sudo docker run -ti $DOCKER_NVIDIA_DEVICES ryanfb/visualsfm /bin/bash`
   * Follow the instructions [here](http://tleyden.github.io/blog/2014/10/25/docker-on-aws-gpu-ubuntu-14-dot-04-slash-cuda-6-dot-5/) for more explanation and to verify CUDA access inside the container

You should now be inside a docker container in your EC2 instance, with a `VisualSFM` command which will use SiftGPU for feature recognition.

### Footnotes

[^siftgpu]: As of this writing on a `g2.2xlarge` instance processing frames from the example in [the previous post]({{ site.baseurl }}{% post_url 2014-10-22-drone_photogrammetry_workflow %}), SiftGPU takes approximately .05-.15 sec/frame vs. 1-2 sec/frame with the CPU-based VLFeat implementation.
