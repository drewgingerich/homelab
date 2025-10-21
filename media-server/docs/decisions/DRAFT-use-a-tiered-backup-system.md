# 10. Use local offline backups

Date: 2023-07-15

## Status

Accepted

## Context

My data loss risk analysis is as follows, with explanations below.

| source           | risk     | impact   | current mitigation |
| ---------------- | -------- | -------- | ------------------ |
| data degradation | low      | low      | strong             |
| user error       | moderate | high     | strong             |
| software error   | low      | moderate | strong             |
| hardware error    | high     | high     | moderate           |
| natural disaster | low      | high     | none               |
| malware          | low      | high     | none               |

[Data degredation](https://en.wikipedia.org/wiki/Data_degradation) is the accumulation of data errors due to non-critical failures in storage medium.
A cosmic ray can flip a bit in flash storage such as RAM or an SSD, for example.
Non-critical failures in storage generally affect a single file at a time, so the impact is low compared to losing everything.
The single file could be an important and irreplaceable document, though, so I believe this data loss vector is still important to address.
The ECC RAM used in the server detects and fixes single-bit errors in memory.
The ZFS filesystem detects and fixes single-bit errors in storage.
Multi-bit errors are possible, but are less likely than single-bit errors.
By using ECC RAM and ZFS, the risk of data loss due to data degradation is currently strongly mitigated.

User error refers to accidentally deleting or corrupting data.
Let's just say that I've forgotten the `.` in `rm -rf ./` before.
ZFS snapshots preserve the state of the filesystem at a point in time,
and provide a way to retrieve files that I've accidentally lost.

Software error refers

- User error
- Software error
- Hardware failure
- Natural disaster
- Malware

- Mirrored vdevs provide some protection against hardware failure.

With these practices in place, I estimate my data loss risk mitigation as follows.

- Data degredation in storage and memory is strongly mitigated.
- User and software error is strongly mitigated.
- Hardware failure is moderately mitigated.
- Matural disaster is unmitigated.
- Malware is unmitigated.

Backups can strongly mitigate almost any risk, depending on how the backups are taken and stored.

- Any backup mitigates risk due to user or software error.
- Regularily checking backup integrity mitigates risk due to data degredation.
- Storing backups outside of the backed-up machine mitigates risk due to hardware failure, and user or software error.
- Keeping backups off-site mitigates risk due to natural disaster.
- Keeping backups off-line or off-site mitigates risk due to basic malware.
- Keeping a long history of backups mitigates risk due to malware and data degredation.
- Immutable backups mitigate risk due to advanced malware that can inflitrate backups.

## Decision

Keep local offline backups of data.

## Consequences

I estimate my data loss risk mitigation will be as follows.

- Strongly mitigated from data degredations in storage and memory
- Very strongly mitigated from user and software error
- Strongly mitigated from hardware failure
- Lightly from natural disaster
- Moderately mitigated from malware

## References

- [The Tao of Backup](http://taobackup.com/index.html)
- [The 3-2-1 Backup Strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)
- [What’s the Diff: 3-2-1 vs. 3-2-1-1-0 vs. 4-3-2](https://www.backblaze.com/blog/whats-the-diff-3-2-1-vs-3-2-1-1-0-vs-4-3-2/)
- [Depressing Storage Calculator](https://jrs-s.net/2016/11/08/depressing-storage-calculator/)
