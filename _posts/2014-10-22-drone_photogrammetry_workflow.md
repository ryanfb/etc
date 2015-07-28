---
title: Open-Source Drone Photogrammetry Workflow
---

Recently I've been playing with using open-source tools to reconstruct 3D models from hobbyist drone videos posted to YouTube (see some sample results [here](https://sketchfab.com/models/90348f4107e94fe5aba97caa86718421) and [here](https://sketchfab.com/models/9161ad0a26ca41379e912f4f291164e3)). This is a writeup of the current workflow I've developed, so other people can give it a try. If you have suggestions or questions (or cool 3D models!), I'm [@ryanfb](https://twitter.com/ryanfb) on Twitter.

Software you'll need: [^1]

 * [youtube-dl](http://rg3.github.io/youtube-dl/)
 * [ffmpeg](https://www.ffmpeg.org/)
 * [VisualSFM](http://ccwu.me/vsfm/) [^2]
 * [MeshLab](http://meshlab.sourceforge.net/)

As a quick overview, the steps in this workflow will be:

 1. download video with `youtube-dl`
 1. extract frames with `ffmpeg`
 1. use VisualSFM to reconstruct a point cloud
 1. import VisualSFM `bundle.rd.out` project and `.ply` point cloud into MeshLab
 1. use Poisson surface reconstruction to compute a mesh for the point cloud
 1. clean up the resulting mesh
 1. compute and project textures onto mesh
 1. simplify and export mesh

First step is finding and downloading a drone video on YouTube. There's actually a surprising number of these, a simple search I like is just looking for ["DJI ruins"](https://www.youtube.com/results?search_query=dji+ruins&page=&utm_source=opensearch) then clicking through to people's channels and related videos.

Now you need to download the video with `youtube-dl`: [^3]

    youtube-dl 'https://www.youtube.com/watch?v=3v-wvbNiZGY'

Next extract (key)frames with `ffmpeg`:

    ffmpeg -i redchurch-3v-wvbNiZGY.mp4 -r 1/1 -qscale:v 1 redchurch_%08d.jpg

The `-r 1/1` flag specifies the rate at which to extract frames (1 frame for every 1 second), so dropping it will extract every frame. [^blurry]

[^blurry]: You may want to extract every frame, then use [the sharpest *n* frames sampled at some regular interval]({{ site.baseurl }}{% post_url 2015-01-22-filtering_video_frames_by_sharpness_for_photogrammetry %}).

Now you want to use VisualSFM to reconstruct a point cloud from your video frames. The first few times you do this it may be helpful to do the reconstruction with the interactive GUI (both to make sure your VisualSFM install actually works, and to see the different steps of the process). There are a few guides online for this process, which I used myself:

 * ["Open Source Photogrammetry: Ditching 123D Catch"](http://wedidstuff.heavyimage.com/index.php/2013/07/12/open-source-photogrammetry-workflow/)
 * ["Generating a Photogrammetric model using VisualSFM, and post-processing with Meshlab"](http://www.academia.edu/3649828/Generating_a_Photogrammetric_model_using_VisualSFM_and_post-processing_with_Meshlab)

A more repeatable, scalable way to do this is to use [the VisualSFM command-line interface](http://ccwu.me/vsfm/doc.html#cmd). This also has the advantage of being able to run non-interactively, so very long reconstructions can be run over SSH or checked in `screen`, and run end-to-end without intervention at each step.

The single-step way to do this for an image sequence from video is:

    VisualSFM sfm+pairs+pmvs ~/redchurch redchurch.nvm @8

Note that the `@8` specifies that, since we have a video sequence instead of a collection of random photos, we want to limit the feature match search range to 8 frames (equivalent to `SfM→Pairwise matching→Compute Sequence Match` in the GUI). Since we're using the command-line, we can also more easily use a larger number of frames with this technique, improving the number of sequence matches.

I've also been experimenting with a multi-pass method for reconstruction that uses keyframes for an initial full pair-wise feature match (which should be more robust to cuts and jumps in the video), then grows the initial set with a sequence match using all frames. I do this by first extracting the keyframes and all frames in two different directories, then using:

    VisualSFM sfm ~/redchurch/keyframes redchurch-initial.nvm; find ~/redchurch/allframes/ -name '*.jpg' > redchurch-initial.nvm.txt; VisualSFM sfm+pairs+resume+pmvs redchurch-initial.nvm redchurch-output.nvm @8

Now, whichever way you've reconstructed a point cloud, you probably want to reconstruct a textured mesh. For this, I use MeshLab. Some of this is described in the previously-linked guides, but for convenience I'll describe the method(s) I use.

First, in MeshLab use `File→Open project…` to open the `bundle.rd.out` file from one of the models reconstructed by VisualSFM. This will be in e.g. `redchurch-output.nvm.cmvs/00/bundle.rd.out`. MeshLab will then prompt you for an image list file which should be `list.txt` in the same directory. Next use `File→Import Mesh…` to open the corresponding `.ply` file in the top-level directory, e.g. `redchurch-output.0.ply`. Note that VisualSFM may reconstruct multiple 3D models from your input, the easiest way to find a good one to start with is to pick the one with the largest `.ply` file. Sometimes the different models may overlap or have different parts of your scene you want to merge together, but I haven't really developed a good workflow in MeshLab or e.g. [CloudCompare](http://www.danielgm.net/cc/) for aligning and merging meshes (getting the different VisualSFM models into the same coordinate system).

Next, you want to actually compute a mesh from your point cloud, clean up the mesh, then texture it with the images from your input. Click the "eye" icon next to the "model" layer in the layer dialog on the right to hide it, then select the `.ply` layer. You may want to rotate/pan/zoom now so that the main cluster of your point cloud is more centered and visible.

Now run `Filters→Point Set→Surface Reconstruction: Poisson`, which will compute a mesh (connected polygons/faces instead of just isolated vertices). I like setting an `Octree Depth` of 10 with a `Solver Divide` of 8 for my first try. Now go ahead and use the layer dialog to hide your original `.ply` point cloud layer, then make sure the `Poisson mesh` layer is selected again.

Poisson surface reconstruction really, really likes closed surfaces, so this may have initially resulted in an incomprehensible bulbous nightmare. Use `Filters→Selection→Select Faces with edges longer than…` to select the (usually-erroneous) huge faces it creates, then use `Filters→Selection→Delete Selected Faces and Vertices` to remove them.[^4]

You may still have some stray isolated blobs or polygons floating around in the model that you want to clean up. You can either use the manual selection/deletion tools to interactively delete these, or use `Filters→Cleaning and Repairing→Remove Isolated pieces (wrt Diameter)` and/or `Remove Isolated pieces (wrt Face Num.)`. The defaults for these are also pretty sane but you can play with them to suit your particular model. If there are now holes left over in the model that you'd like filled before you apply the texture map from your images, you can use the interactive hole fill tool (`Edit→Fill Hole`) or the non-interactive filter under `Filters→Remeshing, Simplification and Reconstruction→Close Holes`.

Now that you have a relatively clean mesh, we want to apply textures to it from our input images. First, because this process requires "manifold" faces, use `Filters→Selection→Select non Manifold Edges`, hit `Apply`, then use `Filters→Selection→Delete Selected Faces and Vertices` to remove any non-manifold faces.

Next use `Filters→Texture→Parameterization + texturing from registered rasters` to do the actual texture mapping. Again the defaults here are pretty sane, but I like to bump the texture resolution up to 4096 (use a power of 2) and go ahead and change the texture name to something suitable to my model. Because texture coordinates are relative (i.e. percent within the image file rather than pixel offset), you can safely calculate a giant texture map in this step then downscale it for size/performance later on with e.g. ImageMagick if you need to.

Now you just need to export your textured mesh. Use `File→Export Mesh As…`, select Alias Wavefront OBJ, and upload your model and texture to a sharing site like [Sketchfab](https://sketchfab.com) (zip up the .obj, .mtl, and .png first) and/or [p3d.in](http://p3d.in/). If your model is too large, you can resize your texture as mentioned earlier, or use `Filters→Remeshing, Simplification and Reconstruction→Quadric Edge Collapse Decimation (with texture)` to simplify your model and re-export, experimenting until you can fit it under the limit.

### Footnotes

[^1]: Complete software installation is out of the scope of this guide, but if you're on a Mac I would suggest using [Homebrew](http://brew.sh/) to install `youtube-dl` and `ffmpeg`. Because VisualSFM is distributed as a binary it can be a hassle to successfully install and use as well. On a Mac, I've had success with [this VisualSFM installer script](https://github.com/luckybulldozer/VisualSFM_OS_X_Mavericks_Installer). I've also now written up [a short guide to using a Docker image I've created for working with VisualSFM]({{ site.baseurl }}{% post_url 2015-01-13-docker_for_visualsfm %}).

[^2]: [As pointed out by Stefano Costa](https://twitter.com/stekosteko/status/524963983577841664), VisualSFM is unfortunately not actually open-source. It does, however, provide a relatively easy to use (though not always easy to install) bundle of and wrapper around the open-source [SiftGPU](http://cs.unc.edu/~ccwu/siftgpu/)/[bundler](http://www.cs.cornell.edu/~snavely/bundler/)/[CMVS](http://www.di.ens.fr/cmvs/)/[PMVS2](http://www.di.ens.fr/pmvs/) photogrammetry toolchain. Presumably this workflow could eventually be rewritten to use those tools directly. Other projects that provide some aggregation of these tools are [PPT](http://opensourcephotogrammetry.blogspot.it/2010/09/python-photogrammetry-toolbox.html)/[osm-bundler](https://code.google.com/p/osm-bundler/)/[PPT-GUI](https://github.com/archeos/ppt-gui/), and [Sean Gillies pointed me to](https://twitter.com/sgillies/status/524986109839671297) another such project I hadn't heard of before called [OpenDroneMap](https://github.com/OpenDroneMap/OpenDroneMap) (appropriately enough).

[^3]: Sometimes, `youtube-dl` won't default to the very highest video quality available on certain videos due to YouTube eccentricities. If there's a high quality version on the page but you automatically get something lower resolution, check available formats with `youtube-dl -F 'url'`, then download with e.g. `youtube-dl -f 136 'url'`. Sometimes this is a video-only stream (which is probably why `youtube-dl` doesn't automatically select it), but since we're doing photogrammetry we don't care about the audio track.

[^4]: If the default value for `Select Faces with edges longer than…` selects too few (or too many) faces for your particular model, just check the preview box and interactively change the value until it looks like it's just selecting erroneous faces.
