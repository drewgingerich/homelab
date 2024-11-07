# 8. Use Restic to back up data

Date: 2023-07-09

## Status

Accepted

## Context

ZFS with redundancy and ECC RAM helps prevent data corruption and downtime.
ZFS snapshots can be used to recover storage state in case of a user or program error messing up the filesystem.
Neither are effective backup solutions because they do not protect data from events that destroy the whole system,
such as flooding and power surges.

## Decision

I will back up my server's data and service configuration regularly,
to minimize the impact.

## Consequences

I will be protected from backup loss, to an degree I find acceptable.

I will need to design a backup system and balance complexity, storage cost, and data safety.

I will need to regularly check that my backup system is working.

## References

- [The 3-2-1 Backup Strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)
- [Depressing Storage Calculator](https://jrs-s.net/2016/11/08/depressing-storage-calculator/)
