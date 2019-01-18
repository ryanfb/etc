---
title: How I failed to replicate an $86 million project in 1 line of code
---

*This post [originally appeared on Medium](https://medium.com/@ryanfb/how-i-failed-to-replicate-an-86-million-project-in-1-line-of-code-615048a1f9d0).*

# How I failed to replicate an $86 million project in 1 line of code

*When an experiment with existing open source technology just cherry-picks results to make it look good*

The Medium article “[*How I replicated an $86 million project in 57 lines of code*](https://medium.freecodecamp.org/how-i-replicated-an-86-million-project-in-57-lines-of-code-277031330ee9)” has been doing the rounds the last few days, describing how an automated license plate recognition (ALPR) system being developed for the Australian Victoria Police could just use the open-source ALPR system [OpenALPR](https://github.com/openalpr/openalpr) instead. This is basically the article-length version of the ubiquitous outraged “Why does this need $X? I could code that up in a weekend!” comments made on any sufficiently-mundane (or complicated!) tech rollout.

However, since OpenALPR *is* free* and open-source, we can test just how plausible this claim is.

Ignoring the boring stuff like getting OpenALPR working on your local computer, let’s jump straight to trying to automatically pull license plates out of a dashcam video. For my test video I picked “[*Drive around Bendigo*](https://www.youtube.com/watch?v=hrD75ebjCms)”, a thrilling 27 minute YouTube video of someone “Driving around Bendigo, Victoria, Australia,” which I felt would be a somewhat representative test, as it’s 1080p car footage that’s quite clear and from around the area where the system will be deployed. After downloading it with youtube-dl I fed it to OpenALPR with `time alpr --clock -n 1 'Drive around Bendigo-hrD75ebjCms.mp4' > bendigo.txt` and let it churn for…

Hm. Well that’s a problem. **Processing my 27 minute video took just over 3.5 hours** on my 3.5GHz Core i7. Not exactly [real-time](https://twitter.com/aallan/status/903713242052165633). Pencil in a few quid for “optimization” and a few more for “ultra-beefy computer hardware in every patrol vehicle” I guess.

![OpenALPR processing time. Yikes.]({{ site.baseurl }}/assets/medium/alpr_command.png)

*OpenALPR processing time. Yikes.*

Anyway, on to [the results](https://gist.github.com/ryanfb/69e5bed7059b7a5187b6d38c0ed6bdcd)! Gotta spend CPU cycles to make…catching thieves easier, as the saying goes. Let’s filter the results down to just the potential license plates with fgrep confidence bendigo.txt. Pipe that in to wc -l and it looks like we’ve got 6,137 potential plates (or 1,653 if we filter those down to unique plate numbers). Not bad! Wait, that seems like a lot. Let’s take a closer look:

    fgrep confidence bendigo.txt| cut -d' ' -f 6 | sort -u | shuf | head
    SURANT
    1IR9DT
    111DIDI
    ARR0W1
    I311
    SGRD
    D1R91T
    0DI10D
    II000
    1ID1

Some of these seem…bad. Ok, no big deal, let’s deploy some of the “very straight forward code-first fixes” proposed in the article like adopting “a threshold […] that only accepts a confidence of greater than 90% before going on to validate the registration number.”

Running `fgrep 'confidence: 9' bendigo.txt | cut -d' ' -f 6 | sort -u` to cut it down to just the 90%+ confidence plate numbers and filter them to only the unique ones, what do we get?

    0G700       HERE      M5ER      TUG700    WKX2D2
    0NRED       HM5ER     MP356     TUG70Q    X036
    1HM5ER      IUG700    R1GHT     TUG70U    XP036
    1IR9IT      JG700     R1LV      TUG7Q0    XS036
    1ZZ735      KEEP      SLV522    TZ2735    XSP036
    DH0SAHUT    KX212     SLV52Z    TZZ735    XSP036E
    ERGE        KX2D2     SLV5Z2    UG700     XSPQ36
    ERQGHT      KXZ12     T0G700    UG70U     YLJ641
    G700        LANE      T0G70U    VKX212    YLJ64D
    GR1L        LJ641     T2Z735    WKX212    YLJ64I
    GRILL       LV522     TDG700

OK, so we still have some apparent duplicates and recognition errors, and presumably the registration validation will sort these out. Checking these with [the VicRoads site](https://www.vicroads.vic.gov.au/registration/buy-sell-or-transfer-a-vehicle/buy-a-vehicle/check-vehicle-registration/vehicle-registration-enquiry), we wind up with **a grand total of seven automatically-recognized “valid” plates for 27 minutes of video**.

[![*One of the handful of plates OpenALPR correctly recognized in the wild. Success!*]({{ site.baseurl }}/assets/medium/alpr_screenshot_1-thumb.jpg)]({{ site.baseurl }}/assets/medium/alpr_screenshot_1.jpg)

**One of the handful of plates OpenALPR correctly recognized in the wild. Success!**

[![Is that T**U**G700 or T**D**G700 in the middle? OpenALPR can’t decide. Both are valid plate numbers. “YLJ641” next to it apparently isn’t in the VicRoads database.]({{ site.baseurl }}/assets/medium/alpr_screenshot_2-thumb.jpg)]({{ site.baseurl }}/assets/medium/alpr_screenshot_2.jpg)

*Is that T**U**G700 or T**D**G700 in the middle? OpenALPR can’t decide. Both are valid plate numbers. “YLJ641” next to it apparently isn’t in the VicRoads database.*

I’m not being intentionally disingenuous here: filtering the plate matches from OpenALPR down to just the “good” ones is a tricky problem. I encourage anyone to try, and post their methods & results. But even beyond filtering the data down to good matches, the basic problem is that OpenALPR outright misses a huge number of clearly-legible plates in every video I’ve thrown at it, and takes forever to do so.

[![This plate is pretty legible in the full-resolution video. OpenALPR recognizes a plate in this one frame, but incorrectly, as “10DID”.]({{ site.baseurl }}/assets/medium/alpr_screenshot_3-thumb.jpg)]({{ site.baseurl }}/assets/medium/alpr_screenshot_3.jpg)

*This plate is pretty legible in the full-resolution video. OpenALPR recognizes a plate in this one frame, but incorrectly, as “10DID”.*

I love open source! I’d love for there to be a free, open source, robust, fast, and accurate ALPR system! It would be great if this project released whatever they do use as open source! But OpenALPR isn’t there yet, and pretending there’s already an open source solution for every problem when there’s *maybe* 25% of a solution there instead is never going to improve its reputation for quality.

Could this project be done for less than $86M? Maybe. Could they use OpenALPR as a starting point? Also maybe. Would it actually reduce the cost? Who knows: it’s a complex project with complex requirements.
