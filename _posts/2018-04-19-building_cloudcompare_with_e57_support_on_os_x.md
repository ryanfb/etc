---
title: Building CloudCompare with E57 Support on OS X
---

The E57 format is used for storing 3D point clouds (from e.g. LiDAR), and is implemented in [libE57](http://www.libe57.org/). Unfortunately, that library is relatively unmaintained, and doesn't build out-of-the-box on OS X. Fortunately, [Andy Maloney has already forked it and patched it to address OS X compatibility and other issues](https://github.com/asmaloney/libE57Format).

[CloudCompare](http://cloudcompare.org/) is a popular cross-platform software package for working with point clouds that uses libE57 for E57 support, but as of this writing the latest distributed OS X build doesn't have E57 support enabled (yet). Since building it myself with E57 support enabled was a little tricky, I wanted to document the process for others. This assumes some command-line familiarity and a working [Homebrew](https://brew.sh/) install, but hopefully it will be of some use.

1. Install the dependencies you'll need to [build CloudCompare](https://github.com/CloudCompare/CloudCompare/blob/master/BUILD.md): `brew install xerces-c qt@5.5 cmake`
2. Clone CloudCompare: `git clone --recursive https://github.com/cloudcompare/trunk.git cloudcompare`
3. Build/install `libE57Format`:
   * `cd cloudcompare/contrib/libE57Format`
   * Edit `CMakeLists.txt` to say `set(Xerces_USE_STATIC_LIBS Off)` instead of `set(Xerces_USE_STATIC_LIBS On)`
   * Run CMake: `XERCES_ROOT="/usr/local/Cellar/xerces-c/3.2.1/" cmake .`
   * Build: `make`
   * Install: `sudo make install` (this will install to `/usr/local/E57Format-2.0-x86_64-darwin`
4. Build CloudCompare:
   * `cd ../..` (get back to the `cloudcompare` root directory)
   * `mkdir build && cd build`
   * Configure CMake: `XERCES_ROOT="/usr/local/Cellar/xerces-c/3.2.1/" CMAKE_PREFIX_PATH="/usr/local/Cellar/qt@5.5/5.5.1_1/lib/cmake/" ccmake ..`
   * Press `c` to configure. Press `e` to exit any warnings, if necessary. Scroll down to `OPTION_USE_LIBE57FORMAT` and press "enter" to toggle it to `ON`
   * Press `c` to configure again. Press `e` to exit warnings again, if necessary. Change `LIBE57FORMAT_INSTALL_DIR` to `/usr/local/E57Format-2.0-x86_64-darwin`
   * Press `c` to configure again. Press `e` to exit warnings again, if necessary. Press `g` to generate config and exit. Press `e` to exit warnings again, if necessary.
   * Build CloudCompare with: `make`
5. Run the resulting CloudCompare app with: `open qCC/CloudCompare.app`
