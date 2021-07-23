---
title: Recovering From a Kernel Panic During Initial FileVault Encryption
tags: mac
---
After upgrading my iMac (late 2013, and thus [T2-chipless](https://support.apple.com/en-us/HT208862) in case you have a T2 chip and the behavior is different for those models) to macOS Catalina 10.15, I noticed that I needed to re-enable FileVault encryption for my startup disk. Soon after doing so, during the initial FileVault disk encryption step, my iMac reported a kernel panic and shut down.

Upon booting up, I was greeted by a login screen which wouldn't recognize any keyboard input for the password field. I then saw a prompt telling me that if this was the case, I should power cycle my Mac to recover the FileVault disk.

After doing so, I got a "Reset Password" recovery boot screen, with the options "I forgot my password", "My password doesn't work when logging in", and "My keyboard isn't working when typing my password to log in".

I selected the last option (since that was the case), and when selecting the user I knew the password for and entering the correct password, was prompted to confirm that I wanted to use it to disable FileVault, and when confirming it would give the error message "The supplied password failed to unlock the disk." I also tried entering the FileVault recovery key here, with no luck.

(As an aside here, I opted to use key-based recovery for FileVault instead of iCloud-based recovery. Luckily I had the key. I assume that if I used iCloud-based recovery, any step where I used the key would be replaced with an iCloud authentication and confirmation step.)

Since that didn't seem to do anything, I also tried the "My password doesn't work when logging in" option to reset my password, but after rebooting still had the same problem that no keyboard input was recognized (trying with both the standard Bluetooth Apple Keyboard I use day-to-day and a wired USB keyboard). Rebooting after the prompt got me back to the same "Reset Password" recovery boot screen with three options.

At this point, I knew I had a working Time Machine backup and figured there was no recovering the mis-encrypted FileVault startup disk, so I tried to go through the only other menu option to erase the disk. However, every time I tried this, I got the error "Couldn't open device (-69877)".

I was seemingly stuck, since normal Recovery Mode startup key combinations didn't seem to get me out of this specific "Reset Password" recovery mode.

Out of desperation, I tried the "I forgot my password" option even though that wasn't the case - and finally got a screen which prompted me for my FileVault recovery key. After typing it in it let me reset the password for my account, and after rebooting my keyboard worked at the login screen and my password (which I reset to be the same password) let me log in, though this initial boot was quite slow.

It seems like this recovery process allowed me to use the FileVault recovery key to re-set my actual password as an acceptable FileVault password to be able to decrypt the startup disk during startup. This was completely counterintuitive, as I had not actually forgotten my password, and nobody else I found having this issue discussed eventually recovering their partially-encrypted FileVault disk in this way.

But, it worked for me, and maybe this post will help someone else out there who doesn't have the option of restoring from backups.

So while you're here, take that as a reminder to make sure you have working backups. I use both Time Machine to a local disk, as well as Backblaze Personal Backup for offsite backups. Sign up for Backblaze using [this link](https://secure.backblaze.com/r/01r46t) and you'll get an extra month free (full disclosure: I'll also get a free month if you decide to subscribe).
