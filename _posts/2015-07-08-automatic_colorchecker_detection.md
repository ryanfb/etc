---
title: Automatic ColorChecker Detection, a Survey
---

A while back (July 2010 going by Git commit history), I hacked together a program for automatically finding [the GretagMacbeth ColorChecker](https://en.wikipedia.org/wiki/ColorChecker) in an image, and [cheekily named it Macduff](https://github.com/ryanfb/macduff). 

The algorithm I developed used adaptive thresholding against the RGB channel images, followed by [contour finding](http://docs.opencv.org/doc/tutorials/imgproc/shapedescriptors/find_contours/find_contours.html) with heuristics to try to filter down to ColorChecker squares, then using k-means clustering to cluster squares (in order to handle the case of images with an [X-Rite ColorChecker Passport](http://xritephoto.com/colorchecker-passport/support)), then computing the average square colors and trying to find if any layout/orientation of square clusters would match ColorChecker reference values (within some Euclidean distance in RGB space). Because of the original use case I was developing this for (automatically calibrating images against an image of a ColorChecker on a copy stand), I could assume that the ColorChecker would take up a relatively large portion of the input image, and coded Macduff using this assumption.

I recently decided to briefly revisit this problem and see if any additional work had been done, and I thought a quick survey of what I turned up might be generally useful:

* Jackowski, Marcel, et al. [*Correcting the geometry and color of digital images*](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=625125&tag=1). Pattern Analysis and Machine Intelligence, IEEE Transactions on 19.10 (1997): 1152-1158.
  Requires manual selection of patch corners, which are then refined with template matching.
* Tajbakhsh, Touraj, and Rolf-Rainer Grigat. [*Semiautomatic color checker detection in distorted images*](http://dl.acm.org/citation.cfm?id=1722754). Proceedings of the Fifth IASTED International Conference on Signal Processing, Pattern Recognition and Applications. ACTA Press, 2008.
  Unfortunately I cannot find any online full-text of this article, and my library doesn't have the volume. Based on the description in Ernst 2013, the algorithm proceeds as follows: "The user initially selects the four chart corners in the image and the system estimates the position of all color regions using projective geometry. They transform the image with a Sobel kernel, a morphological operator and thresholding into a binary image and find connected regions."
* Kapusi, Daniel, et al. [*Simultaneous geometric and colorimetric camera calibration*](http://germancolorgroup.de/html/Vortr_10_pdf/08_FWS_Bildrobo_8_87-94.pdf). 2010.
  This method requires color reference circles placed in the middle of black and white chessboard squares, which they then locate using OpenCV's [chessboard detection](https://en.wikipedia.org/wiki/Chessboard_detection).
* Bianco, Simone, and Claudio Cusano. [*Color target localization under varying illumination conditions*](http://link.springer.com/chapter/10.1007/978-3-642-20404-3_19). Computational Color Imaging. Springer Berlin Heidelberg, 2011. 245-255.
  Uses [SIFT](https://en.wikipedia.org/wiki/Scale-invariant_feature_transform) feature matching, and then clusters matched features to be fed into a pose selection and appearance validation algorithm.
* Brunner, Ralph T., and David Hayward. [*Automatic detection of calibration charts in images*](https://www.google.com/patents/US8073248). Apple Inc., assignee. Patent US8073248. 6 Dec. 2011.
  Uses a scan-line based method to try to fit a known NxM reference chart.
* Minagawa, Akihiro, et al. [*A color chart detection method for automatic color correction*](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?reload=true&tp=&arnumber=6460529&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D6460529). 21st International Conference on Pattern Recognition (ICPR). IEEE, 2012.
  Uses [pyramidization](https://en.wikipedia.org/wiki/Pyramid_(image_processing)) to feed a pixel-spotting algorithm which is then used for patch extraction.
* K. Hirakawa, “[ColorChecker Finder](http://web.archive.org/web/20160920155929/http://campus.udayton.edu/~ISSL/index.php/research/ccfind/),” accessed from `http://campus.udayton.edu/~ISSL/software`. AKA `CCFind.m`.
  The earliest [Internet Archive Wayback Machine snapshot](https://web.archive.org/web/20130315000000*/http://campus.udayton.edu/~ISSL/index.php/research/ccfind/) for this page is in August 2013, however I also found [this s-colorlab mailing list announcement from May 2012](https://list.hig.no/pipermail/s-colorlab/2012-May/000141.html). Unfortunately this code is under a restrictive license: "This code is copyrighted by PI Keigo Hirakawa. The softwares are for research use only. Use of software for commercial purposes without a prior agreement with the authors is strictly prohibited." According to the webpage, "`CCFind.m` does not detect squares explicitly. Instead, it learns the recurring shapes inside an image."
* Liu, Mohan, et al. [*A new quality assessment and improvement system for print media*](http://asp.eurasipjournals.com/content/2012/1/109). EURASIP Journal on Advances in Signal Processing 2012.1 (2012): 1-17.
  An automatic ColorChecker detection is described as part of a comprehensive system for automatic color correction. The algorithm first quantizes all colors to those in the color chart, then performs connected component analysis with heuristics to locate patch candidates, which are then fed to a Delaunay triangulation which is pruned to find the final candidate patches, which is then checked for the correct color orientation.
  This is the same system described in: Konya, Iuliu Vasile, and Baia Mare. [*Adaptive Methods for Robust Document Image Understanding*](http://hss.ulb.uni-bonn.de/2013/3169/3169a.pdf). Diss. Universitäts-und Landesbibliothek Bonn, 2013.
* Devic, Goran, and Shalini Gupta. [*Robust Automatic Determination and Location of Macbeth Color Checker Charts*](https://www.google.com/patents/US20140286569). Nvidia Corporation, assignee. Patent US20140286569. 25 Sept. 2014.
  Uses edge-detection, followed by a flood-fill, with heuristics to try to detect the remaining areas as ColorChecker(s).
* Ernst, Andreas, et al. [*Check my chart: A robust color chart tracker for colorimetric camera calibration*](http://dl.acm.org/citation.cfm?id=2466717). Proceedings of the 6th International Conference on Computer Vision/Computer Graphics Collaboration Techniques and Applications. ACM, 2013.
  Extracts polygonal image regions and applies a cost function to check adaptation to a color chart.
* Kordecki, Andrzej, and Henryk Palus. [*Automatic detection of color charts in images*](http://www.red.pe.org.pl/articles/2014/9/49.pdf). Przegląd Elektrotechniczny 90.9 (2014): 197-202.
  Uses image binarization and patch grouping to construct bounding parallelograms, then applies heuristics to try to determine the types of color charts.
* Wang, Song, et al. *[A Fast and Robust Multi-color Object Detection Method with Application to Color Chart Detection](https://books.google.com/books?id=1vdWBQAAQBAJ&lpg=PA356&dq=bianco%20cusano%20color%20target%20localization&pg=PA350#v=onepage&q=bianco%20cusano%20color%20target%20localization&f=false)*. PRICAI 2014: Trends in Artificial Intelligence. Springer International Publishing, 2014. 345-356.
  Uses per-channel feature extraction with a sliding rectangle, fed into a rough detection step with predefined 2x2 color patch templates, followed by precise detection.
* García Capel, Luis E., and Jon Y. Hardeberg. [*Automatic Color Reference Target Detection*](http://www.ingentaconnect.com/content/ist/cic/2014/00002014/00002014/art00020) ([Direct PDF link](http://colorlab.no/content/download/46569/721683/file/2014_CIC22_GARCIACAPEL_PG119.pdf)). Color and Imaging Conference. Society for Imaging Science and Technology, 2014.
  Implements a preprocessing step for finding an approximate ROI for the ColorChecker, and examines the effect of this for both `CCFind` and a template matching approach (inspired by a project report which I cannot locate online). They also make their software available for download at <http://www.ansatt.hig.no/rajus/colorlab/CCDetection.zip>.

## Data Sets

* [Colourlab Image Database: Imai’s ColorCheckers (CID:ICC)](http://www.ansatt.hig.no/rajus/colorlab/CID-MI.zip) (246MB)
  Used by García Capel 2014. 43 JPEG images.
* [Gehler's Dataset](http://files.is.tue.mpg.de/pgehler/projects/color/index.html) (approx. 8GB, 592MB downsampled)
  * [Shi's Re-processing of Gehler's Raw Dataset](http://www.cs.sfu.ca/~colour/data/shi_gehler/) (4.2GB total)
    Used by Hirakawa. 568 PNG images.
  * [Reprocessed Gehler](http://web.archive.org/web/20160618120032/http://colour.cmp.uea.ac.uk/datasets/reprocessed-gehler.html)
    "We noticed that the renderings provided by Shi and Funt made the colours look washed out. There also seemed to be a strong Cyan tint to all of the images. Therefore, we processed the RAW files ourselves using DCRAW. We followed the same methodology as Shi and Funt. The only difference is we did allow DCRAW to apply a D65 Colour Correction matrix to all of the images. This evens out the sensor responses."
