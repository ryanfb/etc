---
title: 'CyArk Open Heritage Data: Getting the Data'
---

**Update:** I've now finished mirroring all of the data to the Internet Archive [here](https://archive.org/search.php?query=creator%3A%22CyArk%22).

This is the first post in a planned series of posts about getting and using data from the [CyArk Open Heritage Program](http://artsandculture.google.com/project/cyark).

Step one is just getting the data. To do this, you'll need to fill out [this Google Form](https://docs.google.com/forms/d/e/1FAIpQLSehblS2-2A-FKs2q2OxF5i0jDmlJbCQj0GLW3Uc6_WLCRr6rA/viewform) for each dataset you're interested in. If you're interested in all the data, that means you'll need to fill out the form 26 times.

For each dataset, you should receive an email with links to download the data for each dataset. For all the datasets, I received 71 URLs. I copy/pasted each of these URLs into a newline-delimited plaintext file (i.e. one URL per line), which I then downloaded with:

    wget -i cyark-urls.txt

Note that the URLs you receive *do expire*. The expiration token is [a UNIX timestamp](https://www.epochconverter.com/) in the URL (I assume this interacts with the other authentication tokens, so you can't simply change the expiration token), and for me was set to about 2-3 days from when I received the email. So you may need to keep that in mind, depending on how fast you can download (I got about 26MB/s). The total data size is around 1.5TB if you need to do some quick math based on your download speed. Note also that some of the individual files are very large, with the largest being a single 257GB ZIP file, so you may need to make sure the filesystem you're downloading the files to can support that.

Since the URLs are pretty complicated, you wind up with some pretty complicated filenames from `wget`. I used `zsh`'s [`zmv`](http://zshwiki.org/home/builtin/functions/zmv) command to normalize these into something sane by removing the leading and trailing URL components from the filename. So you'll need to run `zsh` if you're not already using `zsh`, then `autoload -U zmv`, then the following in the directory with your downloads:

    zmv 'url\?u=https-3A__storage.googleapis.com_cyark-2Ddata-2Dplatform.appspot.com_(*)' '$1'
    zmv '(*)-3FExpires-(*)' '$1'

Next is extracting the data. All the data is in ZIP files with PDF summaries. Due to the large size of the ZIPs, many ZIP utilities may not work correctly with them. I found [7-Zip](https://www.7-zip.org/) to be the most reliable (`brew install p7zip` on a Mac with [Homebrew](https://brew.sh/)). You can extract the data with e.g.:

    7z x filename.zip

Note that a few of the ZIP files seem to have invalid headers (according to 7-Zip), although they still appear to extract successfully. I tried re-downloading these to see if there was a problem with my download, but received identical files for each. I've written to CyArk to ask about this, but in the meantime the files in question are:

    Al-2520Azem-2520Palace_Al-5FAzem-5FPalace-5FScan-5FData.zip
    Bagan_Bagan-5FKhayiminga-5FPhotogrammetry-5FData.zip
    Waikiki-2520Natatorium_Waikiki-2520Natatorium-5FScan-5FData.zip

I've also produced an SFV file of my downloads after the renaming process described above, if you'd like to check the integrity of your files against my checksums. The SFV is available [here](https://gist.github.com/ryanfb/e27f2abadad7ba5ef35d6eb2ecf00c7b) and you can use it with `cksfv` (`brew install cksfv`) like so:

    wget 'https://gist.githubusercontent.com/ryanfb/e27f2abadad7ba5ef35d6eb2ecf00c7b/raw/dfa0eaf8530b36833cdc74d63a02c95ec829e957/cyark.sfv'
    cksfv -f cyark.sfv

I'm also trying to re-upload the data to the Internet Archive, under the terms of the [CC-BY-NC](https://creativecommons.org/licenses/by-nc/4.0/) license the data is made available under. You should be able to find that data with this search: <https://archive.org/search.php?query=creator%3A%22CyArk%22>

As for using the data, that's another post. The data largely falls into two categories: 3D point clouds in E57 format, and source JPEGs for photogrammetry. Interestingly, there don't seem to be any meshed models distributed with the data, so you're on your own to reconstruct them. For loading the E57 point clouds, you may want to use CloudCompare (if you're a Mac user, see [my previous post on compiling CloudCompare with E57 support enabled]({{ site.baseurl }}{% post_url 2018-04-19-building_cloudcompare_with_e57_support_on_os_x %})). For JPEGs you'll need to process them with [some kind of photogrammetry software]({{ site.baseurl }}{% post_url 2015-01-23-photogrammetry_software_roundup %}).
