# Use restic to back up data

## Problem

I need a way to back up my data.
I'm looking for a tool that provides encryption in transit and at rest,
and minimizes backup size.

## Options

- [restic](https://restic.net/)
- [rclone](https://rclone.org/)
- [BorgBackup](https://www.borgbackup.org/)
- ZFS send to [rsync.net](https://www.rsync.net/products/zfsintro.html)
- [duplicacy](https://duplicacy.com/)
- [kopia](https://kopia.io/)

## Decision

Continue to use restic to back up data.

## Exploration

I have been using restic to back up data for a few years now,
and have had a good experience.

Things I like about it are:

- Encrypts backup in transit and at rest.
- Used by many, which makes me feel confident in its stability.
- Minimizes backup size using compression and deduplication.
- Supports a wide array of cloud storage providers.
- Fast enough: I don't have experience with other backup tools,
  but restic does provide incremental backups and people say it's pretty fast.
- Distributed as a single static binary,
  which makes installation easy and worry-free.

## Related reading

- [The Tao of Backup](http://taobackup.com/index.html)
- [The 3-2-1 Backup Strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)
- [What’s the Diff: 3-2-1 vs. 3-2-1-1-0 vs. 4-3-2](https://www.backblaze.com/blog/whats-the-diff-3-2-1-vs-3-2-1-1-0-vs-4-3-2/)
- [Depressing Storage Calculator](https://jrs-s.net/2016/11/08/depressing-storage-calculator/)

