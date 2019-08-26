---
title: Finding the Most Frequent Senders in Your Gmail Account
---
If your Gmail storage is filling up, you'll be directed to [Google's relatively pathetic instructions for clearing space in Gmail](https://support.google.com/drive/answer/6374270?hl=en) (at the time of this writing, those are "delete emails in Spam" and "delete emails with large attachments"). While that may free up a small amount of space, it's unlikely to make much of a dent if you've been using Gmail for some time. A better way to free up space is to find the most frequent senders and delete all their email you don't care about (newsletters, notifications, ads, spam, etc.).

While I did find [this Python script](https://github.com/adipasquale/mbox-sender-frequency) and [corresponding blog post](https://blog.dipasquale.fr/en/2018/12/02/leave-gmail-in-10-steps/) recommending the same approach, the Python script didn't seem to work correctly on my machine (it seemed like the Python `mailbox` `get_from()` function was returning something other than the expected `From:` field on my mbox file).

So, if you're familiar with the command line, you can use this one-liner on the mbox file you get from [Google Takeout](https://takeout.google.com/) instead:

    grep '^From:' ~/Downloads/Takeout/Mail/All\ mail\ Including\ Spam\ and\ Trash.mbox | cut -d'<' -f2 | tr -d '>' | sort | uniq -c | sort -rn > senders.txt

Sure, it's not perfect, but for `From:` lines that don't conform it still fails gracefully. You can then work your way through the resulting sorted output of most frequent senders and deleting all mail from them (I suggest deleting lines in the output as you delete email, so you can keep track of what you've already deleted). It may take a little while for your storage quota report to update, but I deleted many tens of thousands of emails this way, freeing up about 5GB of storage and getting comfortably back under the quota as a result.
