---
title: Early Usenet History and Archiving
---

Amid some recent handwringing[^handwringing] about the state of digital archiving in general and Usenet archiving in particular, I decided to investigate the state of the current Usenet archives we have available to us. What are they? Where are they? What format are they in? How can we access them? What do they have? What do they omit?[^omissions]

My initial searches turned up the following archives:

* Google Groups - based on the Deja News archive.
* The Internet Archive's "[Usenet Archive of UTZOO Tapes](https://archive.org/details/utzoo-wiseman-usenet-archive)"- 2GB of compressed text total, from between February of 1981 and June of 1991.
* The Internet Archive's "[Usenet Historical Collection](http://archive.org/details/usenethistorical)" - "This historical collection of Usenet spans more than 30 years and was given to us by a generous donor." The archive of `alt.*` groups is 219GB of compressed text.
* "[The Usenet Archive](http://www.theusenetarchive.com/)" - a search site that claims text archives "back to 1980".
* [A-News Archive](https://web.archive.org/web/20000303203929/http://communication.ucsd.edu/A-News/index.html) - "Early Usenet News Articles: 1981 to 1982". This page was originally linked to from [Bruce Jones at UCSD's "Archive for the History of Usenet Mailing List"](http://shikan.org/bjones/Usenet.Hist/index.html) page, but this archive seems to not have survived the migration off UCSD's servers. Therefore, the only live archive seems to be what's in the Internet Archive Wayback Machine.

According to Katharine Mieszkowski's 2002 article, [*The geeks who saved Usenet*](http://www.salon.com/2002/01/08/saving_usenet/), the oldest post in the Deja News/Google Groups archive was on May 11, 1981 by Mark Horton, starting us *in media res* of a thread with the subject "newsgroup fa, net, etc." on `net.general`. This gives us a good starting point to search for in our archives.

* Google Groups - you can find the original thread [here](https://groups.google.com/forum/#!search/%22newsgroup$20fa$2C$20net$2C$20etc.%22/net.general/yJn8WHlzc7U/lPyVdYqCXyAJ), with follow-ups after decades. That thread also had a post pointing to [this post](http://shikan.org/bjones/Usenet.Hist/Nethist/0061.html) on the "usenet.hist" mailing list which contains some archived messages that predate Deja News.
* Internet Archive UTZOO Tapes - extracting `news001f1.tgz` should give us the oldest messages in the archive if the tapes were made in strictly chronological order. Grep can then find us the message we're looking for, in `news001f1/a2/ucbarpa.111`:
  <script src="https://gist.github.com/ryanfb/0bfb66163755bbb067c4.js"></script>
* Internet Archive Usenet Historical Collection - due to the organization of these files, we can just download `net.general.mbox.zip` (2.7MB) from [the `usenet-net` item](https://archive.org/details/usenet-net). Unfortunately the mbox format of these files seems a bit too idiosyncratic for the mailreaders I tried them with. Fortunately, they're still just plaintext. Here's our entry (the headers here seem to indicate this is some sort of dump or scrape of Google Groups data):
  <script src="https://gist.github.com/ryanfb/b982cc39ddfd90c6390d.js"></script>
  
* The Usenet Archive - [no luck](http://www.theusenetarchive.com/index.php?searchmethod=&groupname=net+general&q=%22newsgroup+fa%22&x=0&y=0). I also get zero results [searching in `net.general` from 1980 to 1981](http://www.theusenetarchive.com/index.php?q=&x=0&y=0&groupname=net.general&fromdate=1980&todate=1981).
* A-News Archive: the Wayback Machine has [this snapshot of posts to `net.general` which includes our subject](https://web.archive.org/web/19980423224753/http://communication.ucsd.edu/A-News/NET.general/NET.general-index.html) (and two which predate it!), but no copies of the messages themselves appear to be in the Wayback Machine.

In fact, looking through our `net.general.mbox` file from The Internet Archive Usenet Historical Collection for the `net.general` messages that predate our test message ("DEC on Usenet" and "New Disk Drive") reveals that we can recover one of them:
<script src="https://gist.github.com/ryanfb/b3404ad22eb2dd4c3d05.js"></script>
Note here the difference between the `Date` header and the `X-Google-ArrivalTime` header, which is probably why this wasn't counted as the "oldest" message in the archive.

This is just an initial investigation with one test, and by no means comprehensive. A good next step for someone interested in early Usenet posts would probably be to try to check coverage between the UTZOO collection and the Usenet Historical Collection to see if there are any gaps which can be filled in by merging them together. Another question to try to answer would be how comprehensive the Usenet Historical Collection is for the 1991-on range not covered by the UTZOO collection.

### Footnotes:

[^handwringing]: Matthew Braga. [*Google, a Search Company, Has Made Its Internet Archive Impossible to Search*](http://motherboard.vice.com/read/google-a-search-company-has-made-its-internet-archive-impossible-to-search). Vice Motherboard. Published 2015-02-13. Accessed 2015-02-23.
    
    Andy Baio. [*Never trust a corporation to do a library's job*](https://medium.com/message/never-trust-a-corporation-to-do-a-librarys-job-f58db4673351). Medium. Published 2015-01-28. Accessed 2015-02-23.
    
    Ian Sample. [*Google boss warns of 'forgotten century' with email and photos at risk*](http://www.theguardian.com/technology/2015/feb/13/google-boss-warns-forgotten-century-email-photos-vint-cerf). The Guardian. Published 2015-02-13. Accessed 2015-02-23.
    
    Gareth Millward. [*I tried to use the Internet to do historical research. It was nearly impossible.*](http://www.washingtonpost.com/posteverything/wp/2015/02/17/i-tried-to-use-the-internet-to-do-historical-research-it-was-nearly-impossible/) The Washington Post. Published 2015-02-17. Accessed 2015-02-23.

[^omissions]: Preserving _all_ of Usenet, including all binary postings, would be a pretty daunting task. I'm not really aware of anyone who's actually trying to do that, though even archiving just metadata about binary postings might provide an interesting historical record.
