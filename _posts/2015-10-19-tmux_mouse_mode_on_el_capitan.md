---
title: tmux mouse mode on El Capitan
---

#### UPDATE: With recent releases of `tmux` many configuration options have changed. If you're running `tmux` 2.4 or later please read [this issue comment](https://github.com/tmux/tmux/issues/754#issuecomment-297452143) for a potential resolution.

---

With the release of OS X 10.11 "El Capitan" came a new `Terminal.app` which has different mouse behavior with [`tmux`](https://tmux.github.io/). This affects both copy/paste and scrolling with `tmux` 2.0's `mode-mouse`. If you're running `tmux` 2.0 and have lines like:

    set -g mode-mouse on
    set -g mouse-resize-pane on
    set -g mouse-select-pane on
    set -g mouse-select-window on

In your `~/.tmux.conf`, in El Capitan you'll probably notice you can automatically scroll without having to first enter `copy-mode`. In [`tmux` 2.1](https://raw.githubusercontent.com/tmux/tmux/master/CHANGES), you can replace these lines with just:

    set -g mouse on

However, there's one gotcha with this which is that `tmux` 2.1 apparently also changes the default behavior of mouse scrolling with the new mouse support turned on, so the automatic mouse scrolling you had with `tmux` 2.0 in El Capitan no longer happens by default if you upgrade. If you want it back, you'll need to add lines like this to your `~/.tmux.conf`:

    bind-key -t vi-copy WheelUpPane scroll-up
    bind-key -t vi-copy WheelDownPane scroll-down

Additionally, if you've also set up system pasteboard copying in `tmux` with lines like [what's suggested here](https://robots.thoughtbot.com/tmux-copy-paste-on-os-x-a-better-future): [^pbcopy]

    # Use vim keybindings in copy mode
    setw -g mode-keys vi

    # Setup 'v' to begin selection as in Vim
    bind-key -t vi-copy v begin-selection
    bind-key -t vi-copy y copy-pipe "pbcopy"

    # Update default binding of `Enter` to also use copy-pipe
    unbind -t vi-copy Enter
    bind-key -t vi-copy Enter copy-pipe "pbcopy"

You may notice that under El Capitan you can no longer effectively *select* text in `tmux` to copy with ⌘-C because with mouse mode on it immediately jumps into `copy-mode` on mousedown and out of it on mouseup...never giving you a chance to `pbcopy`. The case here is a little tricky and the answer is not immediately apparent; [what you need to do is trigger `copy-pipe` before releasing the mouse](http://superuser.com/questions/666836/tmux-copy-pipe-with-mouse-selection) (with the config above, by pressing `y` or `Enter` with the mouse still pressed). In `tmux` 2.0 there was also a bug which would cause this to annoyingly re-enter `copy-mode`, but this is fixed in `tmux` 2.1.

One more thing: if you're running El Capitan and `tmux` 2.0, you may have noticed that `notifyd` will occasionally start taking up 99% CPU; [this should also be fixed in `tmux` 2.1](https://trac.macports.org/ticket/49121).

### Footnotes:

[^pbcopy]: The `reattach-to-user-namespace` prefix is [no longer necessary for pasteboard access within `tmux`](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/issues/42).
