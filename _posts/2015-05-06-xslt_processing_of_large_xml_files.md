---
title: XSLT processing of large XML files
---

If you try processing a large XML file with [Saxon-HE](http://saxon.sourceforge.net/) on the command line, you may run into the following error:

> <script src="https://gist.github.com/ryanfb/546d0d571ea9621005c5.js"></script>

If you increase Saxon's memory allocation by passing e.g. the environment variable `JAVA_TOOL_OPTIONS="-Xmx16G"`, you may still get this error:

> <script src="https://gist.github.com/ryanfb/e8e817469880af40148b.js"></script>

The error `java.lang.ArrayIndexOutOfBoundsException: -32768` doesn't seem to be fixable by giving Saxon more memory. This is [a known bug in versions of Saxon prior to 9.6.0.4](https://saxonica.plan.io/issues/2271), unfortunately, the "fix" appears to simply be acknowledging that Saxon won't handle source large source documents, by explicitly throwing the error `java.lang.IllegalStateException: Source document too large: more than 1G characters in text nodes`.

To get around this, I resorted to using [Xalan-J](https://xalan.apache.org/xalan-j/). [Download the binary distribution](https://xalan.apache.org/xalan-j/downloads.html), unzip it, and then you can run it with e.g.:

    JAVA_TOOL_OPTIONS="-Xmx16G" java -classpath ~/source/xalan-j_2_7_2/xalan.jar org.apache.xalan.xslt.Process -INCREMENTAL -IN enwiktionary-20150413-pages-meta-current.xml -XSL filterlatin.xsl -OUT latin.xml

Unfortunately, this limits you to XSLT 1.0 stylesheets.

Note that if you don't give Xalan-J enough memory, you can still run into errors, manifesting themselves as a `org.apache.xml.utils.WrappedRuntimeException` error in the stylesheet.

Thanks to [Yakov Shafranovich](http://blog.shaftek.org/2008/10/20/using-xslt-for-very-large-files/) for pointing out Xalan for this process.
