# Configure storage in RAID 10

## Goals

- Redundancy
- Efficient use of storage
- Flexibility regarding expansion

## Options

## Decision

I will use mirror vdevs in the ZFS pool.

## Side effects

Faster reads than RAID 5.
Mirror vdevs provide good read performance because they allow reading to be distributed across disks.
I can buy disks that prioritize reliability over speed because of this speed boost.

Less intense resilvers than RAID 5.

Lower CPU burden than RAID 5.

Sub-par storage efficiency.
Mirror vdevs do no have high storage efficiency: for a mirror vdev consisting of two disks, only 50% of total storage is usable.
I will spend more money to get the usable storage I require compared to other vdev types such as raidz.

A mirror vdev maintains a copy of the data on each disk in the vdev.

On the other hand, the write performance will be equal to the slowest disk because data must be written to every disk.
I should buy disks that have similar performance characteristics to avoid throttling a high-performance disk.

A mirror vdev provides moderate to high redundancy, depending on how many times the data is mirrored,
because it allows all but one disk to fail in each vdev before the pool is lost.
Even a mirror vdev with two disks gives me enough redundancy to conveniently replace a failed disk without needing to restore from backup.

Mirror vdevs are flexible.
Disks can be added or removed from a mirror vdev, provided the vdev always has at least two disks remaining.
The capacity of a mirror vdev can be upgraded by adding larger disks and then removing the old, smaller disks.


## Context

ZFS creates a storage pool out of multiple devices.
ZFS scatters data across all devices in the pool, and if a single device fails then all data in the pool is lost.

ZFS can create a virtual device (vdev) out of one or more physical devices.
There are several types of vdev,
each using the underlying disks differently to provide different balances between storage space, speed, and redundancy.
Some vdevs are more flexible around adding or removing physical disks, or using disks with different capacities.

I do not need to maximize space because my media collection is not very large and is growing slowly.

Because serving media is a read-heavy workload, I would like good read speed but do not need high write speed.

I would like enough redundancy to handle one or two disk failures.
This is only for convenience, as I will protect my data using backups.

I want flexibility because I'm new to all of this and want the ability to pivot as I learn more.

## References

- [Wikipedia: Standard RAID Levels](https://en.wikipedia.org/wiki/Standard_RAID_levels)
- [A Closer Look at ZFS, Vdevs and Performance](https://constantin.glez.de/2010/06/04/a-closer-look-zfs-vdevs-and-performance/)
- [ZFS: You should use mirror vdevs, not RAIDZ.](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/)
- [NAS RAID Levels Explained: Choosing The Right Level To Protect Your NAS Data](https://www.backblaze.com/blog/nas-raid-levels-explained-choosing-the-right-level-to-protect-your-nas-data/)
