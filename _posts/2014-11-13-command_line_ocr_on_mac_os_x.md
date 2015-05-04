---
title: Command-Line OCR with Tesseract on Mac OS X
---

This is a short writeup of the working process I came up with for command-line OCR of a non-OCR'd PDF with searchable PDF output on OS X, after running into a thousand little gotchas. [^gotchas]

Software Installation
---------------------

  0. Install [homebrew](http://brew.sh/) (if you haven't already).
  1. Install `leptonica` with TIFF support (and every other format, just in case):

         brew install --with-libtiff --with-openjpeg --with-giflib leptonica

  2. Install Ghostscript:

         brew install gs

  3. Install ImageMagick with TIFF and Ghostscript support:

         brew install --with-libtiff --with-ghostscript imagemagick

  4. Install Tesseract devel with all languages: [^devel]

         brew install --devel --all-languages tesseract

  5. Install [pdftk server](https://www.pdflabs.com/tools/pdftk-server/) from the package installer.

Processing Workflow
-------------------

I'm going to assume you have a non-OCR'd PDF you want to convert into a searchable PDF.

  1. Split and convert the PDF with ImageMagick `convert`:

         convert -density 300 input.pdf -type Grayscale -compress lzw -background white +matte -depth 32 page_%05d.tif

  2. OCR the pages with Tesseract: [^lang] [^parallel]

         for i in page_*.tif; do echo $i; tesseract $i $(basename $i .tif) pdf; done

  3. Join your individual PDF files into a single, searchable PDF with `pdftk`: [^merging]

         pdftk page_*.pdf cat output merged.pdf

Now `merged.pdf` should contain your searchable, OCR'd PDF. I've also wrapped this workflow up into [a script](https://gist.github.com/ryanfb/f792ce839c8f26e972cf).

### Footnotes

[^gotchas]: A sampling of the various ways in which Tesseract/Leptonica is picky in its TIFF handling: `Error in pixConvertRGBToGray: pixs not 32 bpp`, `Error in pixReadFromTiffStream: spp not in set`, `Error in pixReadStreamTiff: pix not read`, `Error in pixReadTiff: pix not read`, `Error in pixRead: pix not read`, `Error in findTiffCompression: function not present`, `Error in pixReadStream: Unknown format: no pix returned`, `Error in pixReadStream: tiff: no pix returned`, `Unsupported image type.`
[^lang]: If your document isn't in English, pass the `-l tla` flag as the first argument to `tesseract`. See the `LANGUAGES` section of [`man tesseract`](https://tesseract-ocr.googlecode.com/svn/trunk/doc/tesseract.1.html). You can also install and use your own training data, for example, for [Ancient Greek](http://ancientgreekocr.org/) or [Latin](https://ryanfb.github.io/latinocr/). On OS X, you'll want to copy the `lang.traineddata` file to `/usr/local/share/tessdata`.
[^merging]:
    I initially tried to use the `join.py` Preview Automator script that comes bundled with OS X (at `/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py`), but this seems to mangle the actual OCR text into unsearchable whitespace for me (confusingly, this preserves selectable line/character bounding boxes, so it looks like there's OCR'd text there but there's not). I originally suggested using Ghostscript to combine the PDF files with the command:

        gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf page_*.pdf

    However, this mangles non-Latin scripts. If you would still like to use Ghostscript instead of `pdftk`, the command:

        gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dProvideUnicode -sOutputFile=merged.pdf page_*.pdf

    May give you good, relatively compressed results (from explicitly setting a more modern PDF compatibility level) while preserving non-Latin scripts.

    I realized at the end of writing this guide that you can also use `convert` to create a multipage TIFF (omit the `_%05d` format specifier in your output filename) and process/output that directly with Tesseract, but I like being able to parallelize the OCR,[^parallel] and recombining with pdftk gives me better compression in my testing.

[^devel]: Installing the development version of Tesseract gets you direct PDF output instead of having to recombine text and images from the default [hOCR](http://en.wikipedia.org/wiki/HOCR) output.
[^parallel]:
    If you have [GNU Parallel](http://www.gnu.org/software/parallel/) installed (`brew install parallel`), you can parallelize this process:

        parallel --bar "tesseract {} {.} pdf 2>/dev/null" ::: page_*.tif
