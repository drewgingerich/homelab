# Create ZFS pool with 2-way mirror vdevs

## Relations

Follows up [241106 - Use ZFS to manage media storage](/media-server/docs/decisions/241106-use-zfs-to-manage-media-storage.md)

## Goals

Select an architecutre for the media storage ZFS pool to provide:

- Storage redundancy
- Flexibility around expansion and change
- Simplicity
- Ease of recovery after device failure
- Efficient use of storage space
- Good performance, prioritizing reading data

## Decision

Use 2-way mirror vdevs to create a ZFS pool for media storage.

## Side effects

Faster reads than RAID-Z because reading blocks can be parallelized across disks.
I can buy disks that prioritize reliability over speed because of this speed boost.

Similar write speed as RAID-Z for small files, slower for large files.

Less intense resilvers than RAID-Z.

I don't have to worry about the complexities of RAID-Z.

Expanding drive size in a mirror vdev or adding a mirror vdev to the pool only requires buying two new disks at a time.
RAID-Z would require buying larger batches of disks.

Lower CPU burden than RAID-Z because the CPU doesn't have to calculate parity bits.

50% storage efficiency.

I should buy drives that have similar performance characteristics to avoid throttling a high-performance disk,
and similar storage capacities to avoid wasting extra space in the larger drives.

## Context

I want some storage redundancy because ZFS needs it to be able fix data errors.
Secondarily I want redundancy for the convenience of not having to restore from backup whenever a drive fails.

I'd like flexibility around expansion and change because I'm still learning
and I want to avoid foot-guns.

I also want flexibility to add capacity slowly over time.
Since I only have a few TB of data and it grows slowly over time,
and because storage getting cheaper over time,
it will be cheaper to buy more drives as I need them.

Since my time and brainpower is limited, I greatly value simplicity.

I want recovering from a drive failure to be as easy as possible.
I won't be in the mood to spend a lot of time troubleshooting when a drive fails,
and I want to be confident the recovery process works.

I want high storage efficiency.
Why would I spend more money on drives if I have the option to spend less?

I will also take good performance where it's offered, of course.
Since this is primarily a media storage server,
the workload will be read-heavy.

No storage system can satisfy all of these desires.
I listed them in priority order,
though I adress them in a different order below for flow.

### ZFS pools and vdevs

ZFS creates a storage pool out of one or more virtual devices (vdevs).

ZFS currently provides four types of vdev for storage.
ZFS also provides a few utility types (spare, cache, log, and special) that I don't think are relevant here.

The vdev types for storage are: file, single-device, mirror, [RAID-Z](raidz_docs), and [dRAID](draid_docs).

[raidz_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAID-Z.html
[draid_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/dRAID%20Howto.html

File vdevs use a file from an existing file system as a vdev.
They are primarily intended for testing and experimentation, and not real use.[^8]

Single-device vdevs provide no redundancy.
This means ZFS is not able to fix data errors,
and that when the device fails the whole pool will die.

dRAID is meant for very large arrays of devices beyond what I'll ever use at home.

A mirror vdev stores a redundant copy of data on each device in the vdev.
For example, a 3-way mirror vdev consists of three devices each with one copy of the data.

A RAID-Z vdev stripes data across the devices within the vdev,
along with parity bits to provide redundancy.
RAID-Z can use single, double, or triple parity,
referred to as raidz1, raidz2, and raidz3, respectively.

### Redundancy

Redundancy is how many devices can fail before data is lost.

A mirror vdev with $`d` devices has a redundancy of $`d - 1`$.
Notably, adding devices to a mirror doesn't increase storage capacity, only redundancy.

A RAID-Z vdev with $`d` devices and $`p` parity has a redundancy of $`p`$.

ZFS only provides redundancy at the vdev level:
data in a pool is dynamically distributed across the vdevs,
and if a single vdev fails then all data in the pool is lost.
The robustness of the pool is limited by the weakest vdev,
and a rule of thumb is to create pools using only vdevs with the same redundancy.

### Storage efficiency

Storage efficiency is how much of the total drive capacity can actually be used to store data.

A mirror vdev with $`d` devices has a storage efficiency of $`1 / d`$.
E.g. efficiency of a 2-way mirror is 50%, and a 3-way mirror is 33%.
While mirror vdevs can theoretically have any number of devices,
the storage efficiency quickly lowers prohibitively.

A RAID-Z vdev with $`d` devices and $`p` parity has a storage efficiency of $`d - p / d`$.
Increasing vdev width increases efficiency, while increasing parity lowers efficiency.
E.g. efficiency of a 3-wide raidz1 is 66%, a 4-wide raidz2 is 50%, and an 11-wide raidz3 is 72%.
RAID-Z almost always provides better storage efficiency than mirrors.

ZFS treats all devices in a vdev as having the same capacity as the smallest device in the vdev.
Using devices of unequal size will waste the extra space on the larger devices.

### Flexibility

Mirror vdevs can have devices added or removed after creation.

Mirror vdev storage capacity can be increased by replacing all devices in the vdev with larger devices.

Having a RAID-Z vdev in a pool prevents any vdev from being removed from the pool.[^1]

RAID-Z vdevs can have new devices added[^2], but not removed.
Adding a device will not reflow existing data, so existing data will still have the original storage efficiency.
In practice this is not a big deal: RAID-Z doesn't guarantee the full storage efficiency for every block anyways,[^4]
and reflow happens naturally over time due to copy-on-write.

The parity level of a RAID-Z vdev cannot be changed after creation.

### Performance

Mirror write speed is limited by the slowest devices in the vdev,
since the data needs to be written to every device.

Mirror single reads perform at average speed of the disks in the vdev, since data will be read off one of the devices at random.
Mirrors can provde improved performances for concurrent reads since the reads can be spread across multiple devices.

RAID-Z write performance
RAID-Z incurs some CPU load in order to calculate the parity bits.
I'm not sure how much in practice.

ZFS requires thinking about performances at two levels: performance of a pool and performance of a vdev.

Pool IOPS is a function of the number of vdevs, because both mirrors and RAID-Z perform like the average device in the vdev.
2-way mirror pools

It is a best practice to create pools using vdevs with the same performance characteristics (same type and same underlying devices).[^6]
This makes performance and reliability more predictable,
as different vdev and device types exhibit different behaviors,
and which vdev and device is used for an operation is unpredictable.

### Failure recovery

When a vdev with redundancy has a device fail, it enters a degraded state.
Different vdev types exhibit different behaviors when degraded.

When a failed disk is replaced with a healthy disk,
ZFS performs a _resilver_ to 

Mirror vdev devices failure don't affect performance much.

with the exception being concurrent read performance since reads cannot be distributed across as many devices.

When resilvering a mirror, ZFS copies data from the healthy devices over to the new devices.

When a device fails, RAID-Z performance is severly degraded because all devices must be read in order
to do the parity calculations necessary to cover for the failed device.
What happens when writing to a degraded RAIDz array?

Recovering from a RAID-Z device failure involves reading from all remaining devices to recreate the missing data.
This places a lot of load on the remaining disks,
and anecdotally the odds of a second failure during a RAID-Z resilver are uncomfortably high.[^7]
The general wisdom of the internet recommends skipping raidz1 in favor of raidz2, or even raidz3.

How to choose RAID-Z width?[^4]
The wider the array and the larger the disks,
the longer and more intense a resilver will be.
Choosing certain sizes can avoid storage overhead.[^6]
Rule of thumb that RAID-Z vdev device counts should be kept to single digits or low teens.

Resilver duration will be similar to scrub duration, since they are the same operation.
My scrubs take 3.5 hours.

### Simplicity

Configuring RAID-Z vdevs is more complicated than configuring mirror vdevs.

RAID-Z presents more axis of choice, and striping + parity is more complicated than simple copies.
RAID-Z data disks could be powers of 2, e.g. 10 disk raidz2 for 8 data disks.

## References

[^1]: https://serverfault.com/questions/1142074/why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool
[^2]: https://openzfs.github.io/openzfs-docs/man/master/8/zpool-attach.8.html
[^3]: https://en.wikipedia.org/wiki/Parity_bit
[^4]: https://www.delphix.com/blog/zfs-raidz-stripe-width-or-how-i-learned-stop-worrying-and-love-raidz
[^5]: http://nex7.blogspot.com/2013/03/readme1st.html
[^6]: https://jro.io/truenas/openzfs/
[^7]: https://jro.io/r2c2/
[^8]: https://docs.oracle.com/cd/E19253-01/819-5461/gazcr/index.html

[Wikipedia: Standard RAID Levels](https://en.wikipedia.org/wiki/Standard_RAID_levels)
[NAS RAID Levels Explained: Choosing The Right Level To Protect Your NAS Data](https://www.backblaze.com/blog/nas-raid-levels-explained-choosing-the-right-level-to-protect-your-nas-data/)
https://www.reddit.com/r/zfs/comments/3gpkm9/statistics_on_realworld_unrecoverable_read_error/
https://www.truenas.com/community/resources/assessing-the-potential-for-data-loss.227/
https://www.zdnet.com/article/why-raid-5-stops-working-in-2009/
https://queue.acm.org/detail.cfm?id=1670144

https://static.ixsystems.co/uploads/2020/09/ZFS_Storage_Pool_Layout_White_Paper_2020_WEB.pdf
https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/
[A Closer Look at ZFS, Vdevs and Performance](https://constantin.glez.de/2010/06/04/a-closer-look-zfs-vdevs-and-performance/)
[ZFS: You should use mirror vdevs, not RAID-Z.](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/)
[ZFS Raidz Performance, Capacity and Integrity](https://calomel.org/zfs_raid_speed_capacity.html)

https://arstechnica.com/gadgets/2020/05/zfs-versus-raid-eight-ironwolf-disks-two-filesystems-one-winner/
https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/

https://blocksandfiles.com/2022/06/20/resilvering/
