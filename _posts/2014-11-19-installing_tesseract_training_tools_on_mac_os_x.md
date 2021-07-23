---
title: Installing Tesseract training tools on Mac OS X
tags:
- ocr
- mac
---

#### Update (2015-09-08):
[A pull request I submitted to Homebrew](https://github.com/Homebrew/homebrew/pull/43223) to add a `--with-training-tools` option to the `tesseract` formula has now been accepted, so you should be able to just do `brew install --with-training-tools tesseract`. Please submit any issues with the training tools under OS X to [the Tesseract project on GitHub](https://github.com/tesseract-ocr/tesseract).

***

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

I decided to try building against `--HEAD` but got some link errors during the training build. After some more thorough hacking of the formula, I got something that built, linked, and apparently worked. You can see the formula [here](https://github.com/ryanfb/homebrew/blob/tesseract_training/Library/Formula/tesseract.rb).

After running `brew uninstall tesseract` first to remove any existing install, you can build and install my version of the formula with:

    brew install --training-tools --all-languages --HEAD https://raw.githubusercontent.com/ryanfb/homebrew/tesseract_training/Library/Formula/tesseract.rb

You should now be able to do e.g.:

    text2image --list_available_fonts

Note that `fontconfig` font locations and caching are a whole other nightmare, and I seem unable to get `text2image` to respect/use the `--fonts_dir` argument on OS X. Your best bet seems to be to install things as system/user fonts (e.g. copy into `~/Library/Fonts`) and optionally run `fc-cache -frv` to force a cache update.

### Footnotes

[^scrollview]: Googling these problems lead to [this unresolved thread on the tesseract-ocr mailing list](https://groups.google.com/forum/#!topic/tesseract-ocr/wdTWg7Qkb_g), where I've actually copied the error example from as mine is now lost to the great scrollbuffer in the sky.
