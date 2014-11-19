---
title: Installing Tesseract training tools on Mac OS X
---

In [my previous post]({{ site.baseurl }}{% post_url 2014-11-13-command_line_ocr_on_mac_os_x %}) I outlined getting Tesseract working for OCR of PDF's on OS X. In this post, I'd like to document how to install and use the Tesseract training tools.

My first efforts at crudely getting the training tools built and installed were just adding the necessary `make` commands to the Homebrew formula and reinstalling `--devel`. However, this resulted in some bizarre problems in even getting the `text2image` command to run: [^scrollview]

    $ text2image --list_available_fonts 
    Error resolving name for ScrollView host --list_available_fonts:8461 
    Segmentation fault: 11

    $ text2image localhost --list_available_fonts
    Starting sh -c "trap 'kill %1' 0 1 2 ; java -Xms1024m -Xmx2048m -Djava.library.path=. -cp ./ScrollView.jar:./piccolo2d-core-3.0.jar:./piccolo2d-extras-3.0.jar com.google.scrollview.ScrollView & wait"
    ScrollView: Waiting for server...
    Error: Could not find or load main class com.google.scrollview.ScrollView
    sh: line 0: kill: %1: no such job
    ScrollView: Waiting for server...
    ScrollView: Waiting for server...
    ScrollView: Waiting for server...
    ScrollView: Waiting for server...
    ScrollView: Waiting for server...
    ^C

I decided to try building against `--HEAD` but got some link errors during the training build. After some more thorough hacking of the formula, I got something that built, linked, and apparently worked. You can see the formula [here](https://github.com/ryanfb/homebrew/blob/tesseract_training/Library/Formula/tesseract.rb), and pull it into your Homebrew repo with e.g.:

    cd /usr/local/Library/Formula
    git remote add ryanfb https://github.com/ryanfb/homebrew.git
    git fetch ryanfb
    git show ryanfb/tesseract_training:Library/Formula/tesseract.rb > tesseract.rb

Now you can build and install (`brew uninstall tesseract` first to remove any existing install):

    brew install --training-tools --all-languages --HEAD tesseract

You should now be able to do e.g.:

    text2image --list_available_fonts

Note that `fontconfig` font locations and caching are a whole other nightmare, and I seem unable to get text2image to respect/use the `--fonts_dir` argument on OS X. Your best bet seems to be to install things as system/user fonts (e.g. copy into `~/Library/Fonts`) and optionally run `fc-cache -frv` to force a cache update.

[^scrollview]: Googling these problems lead to [this unresolved thread on the tesseract-ocr mailing list](https://groups.google.com/forum/#!topic/tesseract-ocr/wdTWg7Qkb_g), where I've actually copied the error example from as mine is now lost to the great scrollbuffer in the sky.
