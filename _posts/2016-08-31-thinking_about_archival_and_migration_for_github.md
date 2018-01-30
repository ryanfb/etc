---
title: Thinking about Archival and Migration for GitHub
---

Given the increasing centrality of GitHub for hosting code and data for a variety of projects, we owe it to ourselves to think about what our long-term plans are for preserving these resources. While GitHub very generously provides a huge amount of resources for free, it's still a company, and could change their terms or discontinue services at their whim. [What would you do if GitHub shut down tomorrow](http://www.infoworld.com/article/3028174/open-source-tools/what-would-you-do-if-github-shut-down-tomorrow.html)? [^chicken-little]

The knee-jerk reaction from some people might be: "oh, no problem, since Git is *distributed* by default, I can just push my Git repositories to another server." I know this because it's my first thought as well. But on closer scrutiny, unless you're planning in advance, you stand a good chance of losing a lot of work if you're hoping for this to save you. Do you have all your GitHub issues and pull requests backed up? Do you clone and update all your Git-backed wikis? Do you collaborate on repositories you haven't fetched from in a while?

Furthermore, even if **you're** planning in advance, that doesn't mean everyone else is. The network effects of GitHub shutting down would be tremendous. Much like Google Code or SourceForge, there will be a huge number of projects hosted there which have fallen out of maintenance but still have value. Those sorts of projects are particularly unlikely to be thinking about archival and migration. If we're going to rely on GitHub, we can't just consider the archival problem solved once we've taken care of "our stuff."

Tugging on this thread a little more, I think this highlights that there are really two separate problems we need to consider when thinking and talking about this issue:

1. **Archival**. If GitHub goes away, how do we *access stuff* that was hosted there? What sorts of things do we want to archive (Git repositories, issues, wikis, organizational structures, code forking networks, etc.)?
2. **Migration**. If GitHub goes away, how do we *move somewhere else* for projects with ongoing maintenance or active development? What sorts of things do we want to move?

I don't have perfect solutions ready for either of these problems.[^glass-houses] What I want to do instead is offer a starting point for discussion of these problems, and point out some existing work.

## Archival

Luckily, there are a few projects already working on some of the challenges of "archiving GitHub": [^archiveteam]

* [Software Heritage](https://www.softwareheritage.org/) is working to archive all "public, non-fork repositories from GitHub"
* [GitHub Archive](https://www.githubarchive.org/) and [GHTorrent](http://ghtorrent.org/) are working on providing archives of the entire GitHub public "events" timeline

There are also some existing software projects that can help back up individual repositories or entire accounts:

* [github-backup](http://github-backup.branchable.com/)
* [github-records-archiver](https://github.com/benbalter/github-records-archiver)
* [BackHub](https://backhub.co/)

You can also use [Zenodo's GitHub integration](https://guides.github.com/activities/citable-code/) to generate DOI's for archived release snapshots from GitHub repositories. Similarly, the [Open Science Framework](https://osf.io/) offers GitHub integration and file archiving.

The question then is: are these enough, or do we need to step up to ensure we're *actively* archiving the things we want to keep, before it's too late?

## Migration

The main thing that springs to mind here is to run your own GitHub-a-like server, and migrate your repositories into it. There are a few options available here, some of which also offer hosted services similar to GitHub:

* [GitLab](https://about.gitlab.com/) - written in Ruby/Rails, offers a hosted service. Also offers [GitHub import](http://docs.gitlab.com/ce/workflow/importing/import_projects_from_github.html).
* [Phabricator](https://github.com/phacility/phabricator) - written in PHP, offers a hosted service. Apparently working on GitHub issue import/sync.
* [Gogs](https://gogs.io/) - written in Go. Import of GitHub issues doesn't seem readily available as of this writing.
* [Bitbucket Server](https://www.atlassian.com/software/bitbucket/server) - non-free for self-hosted, and also offers a hosted service. There are some [third-party solutions for migrating issues from GitHub](http://codetheory.in/export-your-issues-and-wikis-from-github-repo-and-import-to-bitbucket-migration/).

Of course, none of these directly address the long-term concern of "who's going to pay for this?" There are [models for doing this kind of thing for academic projects](https://twitter.com/ekansa/status/766661680482910209), but none that I know of operating in this space. Another concern for productivity and cost-effectiveness might be trying to coordinate our "archival" and "migration" activities so that the archives can be used for migration (and ensuring that whatever we migrate *to* can also be archived).

Another question is: how much do we need to worry about this in advance of needing it? I don't think there's an easy, universally "right" answer for this as there's always going to be some tradeoffs. For example, hosting a live mirror of your GitHub repositories somewhere else will help ensure you can migrate if or when you need to, but until then it just adds maintenance overhead.

There's always a tension between distribution and centralization of resources. GitHub is great because all sorts of disparate resources are in one place with a common interface, but that also means there's a single point of failure if GitHub goes away. If every project ran their own GitHub-like site, there'd be no single point of failure, but you'd also probably have a lot more frustration with the idiosyncrasies of each individual site.

### Acknowledgments

This post was borne out of a series of discussions on Twitter, without which it would have probably just percolated as a nagging anxiety in the background of my mind:

* <https://twitter.com/mlsatlow/status/740555142487937024>
* <https://twitter.com/ekansa/status/766658233318662144>
* <https://twitter.com/diyclassics/status/770988527303680000>

### Footnotes:

[^chicken-little]: Some people's reaction to this entire post might be "But it's **GitHub**, why worry? They'll be around forever!" I always wonder if these are the same people who, after a website shuts down, say: "What did you expect? They're a company, it's their stuff, they can do what they want!"
[^glass-houses]: As you may be reading this post on a 'github.io' subdomain, I'm obviously not 100% prepared for GitHub dying tomorrow myself.
[^archiveteam]: Many of these resources are linked from the [Archive Team Wiki "GitHub" page](http://www.archiveteam.org/index.php?title=GitHub).
