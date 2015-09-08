---
title: Experimenting with OpenCL for Tesseract
tags:
- ocr
- docker
---

#### Update (2015-09-08):
[A pull request I submitted to Homebrew](https://github.com/Homebrew/homebrew/pull/43223) to add a `--with-opencl` option to the `tesseract` formula has now been accepted, so you should be able to just do `brew install --HEAD --with-opencl tesseract`. For issues with OpenCL-enabled Tesseract on OS X, please see [this issue](https://github.com/tesseract-ocr/tesseract/issues/71).

***

After coming across [these instructions for building Tesseract with OpenCL support](https://code.google.com/p/tesseract-ocr/wiki/TesseractOpenCL), I wanted to experiment with this feature to see if it would enable faster OCR processing. I also came across [this blog post](http://www.sk-spell.sk.cx/tesseract-meets-the-opencl-first-test) experimenting with the feature under Linux and Windows, but I wanted to try it on Mac OS X and AWS EC2 GPU instances.

## Using Mac OS X with Homebrew

Here I built off [my existing work modifying the Tesseract Homebrew formula to install the Tesseract training tools]({{ site.baseurl }}{% post_url 2014-11-19-installing_tesseract_training_tools_on_mac_os_x %}).

The only gotcha (as I serendipitously found out) is that there appears to be a bug in the OpenCL build under OS X that will cause it to fail if you don't have a `/opt/local` directory for it to include. As I didn't feel like fixing this, you can simply work around it by running `sudo mkdir -p /opt/local` before installing with the command:

    brew install --training-tools --all-languages --opencl --HEAD https://github.com/ryanfb/homebrew/raw/tesseract_training/Library/Formula/tesseract.rb

If all went well, you should now have an OpenCL-enabled build of Tesseract.

## Using an AWS GPU-Enabled Docker Host

For this I built off [my existing work using Docker for VisualSFM under AWS]({{ site.baseurl }}{% post_url 2015-01-13-docker_for_visualsfm %}). I've published the Docker build for this on Docker Hub as [`ryanfb/tesseract-opencl`](https://registry.hub.docker.com/u/ryanfb/tesseract-opencl/). For clarity, I'll repeat the instructions for using this on EC2 here:

 * [Launch an EC2 instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-instance_linux.html) with instance type `g2.2xlarge`, community AMI `ami-2cbf3e44`, and 20+ GB of storage
 * [Connect to your EC2 instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-connect-to-instance-linux.html)
 * Install `docker` inside your EC2 instance:
   * `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9`
   * `sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"`
   * `sudo apt-get update`
   * `sudo apt-get install lxc-docker`
 * Run a GPU-enabled Tesseract docker image:
   * Build the CUDA samples and run `deviceQuery` inside your Docker host (this seems to be necessary to init the nvidia devices in `/dev`):
     * `cd ~/nvidia_installers`
     * `sudo ./cuda-samples-linux-6.5.14-18745345.run -noprompt -cudaprefix=/usr/local/cuda-6.5/`
     * `cd /usr/local/cuda/samples/1_Utilities/deviceQuery`
     * `sudo make`
     * `./deviceQuery`
   * Find your nvidia devices with: `ls -la /dev | grep nvidia`
   * Set these as `--device` arguments in a variable you'll pass to the `docker run` command:
     * `export DOCKER_NVIDIA_DEVICES="--device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm"`
     * `sudo docker run -ti $DOCKER_NVIDIA_DEVICES ryanfb/tesseract-opencl /bin/bash`
   * Follow the instructions [here](http://tleyden.github.io/blog/2014/10/25/docker-on-aws-gpu-ubuntu-14-dot-04-slash-cuda-6-dot-5/) for more explanation and to verify CUDA access inside the container

## Results

With OpenCL suppport enabled, an initial run of `tesseract` will perform some automatic device detection and profiling on first run and save the results to various `.bin` files and a `tesseract_opencl_profile_devices.dat` file in the current working directory, which it will re-use on subsequent runs.

Here's the diagnostic information for the three machines I tested with:

<script src="https://gist.github.com/ryanfb/3f6c266f86bc9e8c5ac6.js"></script>

Here, `(null)` is the non-OpenCL Tesseract implementation (i.e. what you get if you build without OpenCL). You can see that on OS X, the OpenCL implementation also detects/reports the CPU as an available device for OpenCL. "Score" is the result of the timing profile, so higher values are worse. I'm not sure if the profiling/timing is correct on OS X or the OpenCL implementation is just simply always outperformed by the general implementation, but we can see on both sets of hardware here that that's what gets selected.

The AWS EC2 `g2.2xlarge` results appeared promising, but in practice (testing my OCR process against [this 527-page volume](https://archive.org/details/virorumceleberr01bousgoog)) I didn't notice a giant speed improvement over running it on my iMac (about 20 vs. 30 minutes).

So, I think I'll be sticking to building Tesseract without OpenCL for now. I think there are still great parallelization improvements that could be made in Tesseract, especially in the training process, but the current OpenCL implementation doesn't appear to have completely solved that problem.
