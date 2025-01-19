# Create ZFS pool with 2-way mirror vdevs

## Relations

Follows up [241106 - Use ZFS to manage media storage](/media-server/docs/decisions/241106-use-zfs-to-manage-media-storage.md)

## Goal

Select ZFS pool layout for media storage.

## Options

1. 2-way mirror vdevs
2. 3-way mirror vdevs
3. raidz1 vdevs
4. raidz2 vdevs
5. raidz3 vdevs

## Decision

Use 2-way mirror vdevs to create a ZFS pool for media storage.

## Effects

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

## Assessment

I want storage redundancy because ZFS needs it to be able fix data errors.
This means one redundant copy of data.

I secondarily want redundancy for the convenience of not having to restore from backup whenever a drive fails.
This means at least one redundant copy of data, possibly more to reliably not have to restore from backup.

I'd like flexibility around expansion and change because I'm still learning
and I want to avoid foot-guns.

I also want flexibility to be able to add capacity slowly as needed.
Since I only have a few TB of data and it grows slowly,
and because storage getting cheaper as time passes,
it will be cheaper to buy drives as I need them.

I want recovering from a drive failure to be easy, fast, and low-stress.
I won't be in the mood to spend a lot of time troubleshooting when a drive fails,
and I want to be confident the recovery process works.

Since my time and brainpower is limited, I greatly value simplicity.

I want high storage efficiency.
Why would I spend more money on drives if I have the option to spend less?

I will also take good performance where it's offered.
Since this is primarily a media storage server,
the workload will be read-heavy.

To summarize, I am looking for:

- Storage redundancy
- Flexibility around maintenance: changing device count and capacity
- Reliable and fast recovery after device failure
- Simplicity
- Space efficiency
- Good read performance

No storage system can satisfy all of these desires.
I have listed them in priority order.

### ZFS pools and vdevs

A ZFS storage pool is a high-level abstraction over physical devices that
allows them all to be treated as one monolithic pool of storage.

A ZFS storage pool is created out of one or more virtual devices (vdevs).
A vdev is also an abstraction over physical devices, at a lower level than a pool,
that allows several devices to be treated as a single device with properties
depending on the type of vdev.

Many of ZFS' features are provided at the vdev level,
such as data redundancy and error correction.

ZFS currently provides four types of vdev for storage:
file, single-device, mirror, [RAID-Z](raidz_docs), and [dRAID](draid_docs).

[raidz_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAID-Z.html
[draid_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/dRAID%20Howto.html

ZFS also provides a few utility types: spare, cache, log, and special.
They don't seem relevant for this assessment.

File vdevs use a file from an existing file system as a vdev.
They are primarily intended for testing and experimentation, and not real use.[^8]

Single-device vdevs store data on a single device (who'd have thought).
Since single-device vdevs provide no redundancy, ZFS is not able to correct data errors.
When the device fails the vdev is lost.

A mirror vdev stores a redundant copy of data on each device in the vdev.
For example, a 3-way mirror vdev consists of three devices each with one copy of the data.

A RAID-Z vdev stripes data across the devices within the vdev,
along with parity bits to provide redundancy.
RAID-Z can use single, double, or triple parity,
referred to as raidz1, raidz2, and raidz3, respectively.

dRAID is an evolution of RAID-Z meant for very large arrays of devices, beyond what I'll ever use at home.

Out of all of these, mirrors and RAID-Z fit my use-case.

### Redundancy

Redundancy is how many devices can fail in a vdev before data is lost.

ZFS pools do not provide any redundancy,
and redundancy is instead handled at the vdev level.
The robustness of the pool is hence limited by the weakest vdev.
A rule of thumb is to create pools using vdevs of the same redundancy.

A mirror vdev with $`d` devices has a redundancy of $`d - 1`$,
e.g. a 3-way mirror has a redundancy of 2.

A RAID-Z vdev with $`d` devices and $`p` parity has a redundancy of $`p`$,
e.g. raidz2 has a redundancy of 2 regardless of the number of disks in the vdev.

Mirror and RAID-Z vdevs can both have excellent redundancy,
but redundancy comes at a heavy cost of storage efficiency for mirror vdevs.

### Storage efficiency

Storage efficiency is how much of the total drive capacity can actually be used to store data.

ZFS treats all devices in a vdev as having the same capacity as the smallest device in that vdev.
Using devices of unequal size will waste the extra space on the larger devices,
so a rule of thumb is match the capacity of all devices within a vdev.

A mirror vdev with $`d` devices has a storage efficiency of $`1 / d`$.
E.g. efficiency of a 2-way mirror is 50%, and a 3-way mirror is 33%.

A RAID-Z vdev with $`d` devices and $`p` parity has a storage efficiency of $`d - p / d`$.
Increasing the number of devices in the vdev (referred to as _width_) increases efficiency,
while increasing parity lowers efficiency.
E.g. efficiency of a 3-wide raidz1 is 66%, a 4-wide raidz2 is 50%, and a 10-wide raidz3 is 70%.

RAID-Z almost always provides better storage efficiency than mirrors.

### Performance

Performance is a deep topic and highly depends on workload,
and collecting real data is more effective than theorizing.
Still, I'll do a bit of theorizing to get a general sense and predictions,
looking at maximum IOPS and throughput for read and write operations.

The performance of a pool trends towards the average performances of its vdevs,
because ZFS distributes operations across the vdevs.
Having slow vdevs will undermine the performance of fast vdevs.
A rule of thumb is to use vdevs with similar performance,
most easily done use identical vdev and device types.[^6]

Pool IOPS is a function of the number of vdevs, because both mirrors and RAID-Z perform like the average device in the vdev.
2-way mirror pools

Since writes to a mirror must write the full data to every device,
write performance is limited by the slowest device in the vdev.
In other words, write IOPS and throughput are equivalent to a single disk and don't scale.

Since every device in a mirror has a full copy of the data,
a read can be done from any device and read performance is the sum
of the devices in the vdev.
This is true for small files, but large files are equal to one disk, ya?

RAID-Z incurs some CPU load in order to calculate the parity bits,
but this is much faster than storage IO and is not a limiting factor for performance.

Since data is broken up and written across all devices in the vdev, 
writes can be parallelized and write performance is the sum of all the devices.

Reads are limited by the slowest device.

### Failure recovery

A vdev with redundancy can have a drive fail and continue to function.
This gives an opportunity to replace the failed drive before data is lost.

When a faulty drive is replaced, ZFS will move data to the new device with an operation called a _resilver_.
A resilver is actually the same a _scrub_, which is a maintenence task that goes through a pool to find and correct errors.

A resilver is an intensive operation for the devices in a vdev because
all the data must be read from the remaining devices and written to the new device.
This brings a chance for more devices to fail during the resilver.
As the amount of data moved around during a resilver grows, the odds of a second failure grow as well.

If the vdev doesn't have enough redundancy for a second failure, then data will be lost.
For a bad sector this means a corrupt file: since ZFS manages the filesystem as well as storage devices,
it knows the file associated with the bad sector and that other files are okay.
For a complete device failure, most or all files in the pool will be corrupted:
since ZFS distributes data across all vdevs, most files will have blocks on every vdev.

Anecdotally the odds of a second failure during a RAID-Z resilver are uncomfortably high[^7].
Compared to mirrors, a resilver of RAID-Z vdev involves much more device activity:
they generally have more devices and hence more capacity, and must read parity bits to recreate missing data.
The general wisdom of the internet recommends skipping raidz1 in favor of raidz2, or even raidz3.

RAID-Z width is mainly limited by
How to choose RAID-Z width?[^4]
Choosing certain sizes can avoid storage overhead.[^6]
Rule of thumb that RAID-Z vdev device counts should be kept to single digits or low teens.

Mirror vdevs have faster and safer recovery because of their smaller size,
though for 2-way mirror vs raidz2 this is weighed against having a lower redundancy.

### Flexibility

Storage needs grow over time, while storage gets cheaper over time.
Fiscally it makes sense roughly meet current storage needs now,
and expand storage when needed.
I want my ZFS pool layout to be flexible about how it can grow.

I also want flexibility to change properties like storage efficiency and
redundancy, in case I find a better setup as I learn more.
ZFS and storage is a deep topic, so I wouldn't be surprised.

ZFS imposes some constraints on how vdevs can be changed once created,
with different vdev types having different constraints.

Mirror vdevs can have devices added or removed after creation.
Adding or removing devices doesn't incur any hidden cost or state.

RAID-Z vdevs can have new devices added[^2], but not removed.
Adding a device will not re-flow the data, so existing data will keep the original storage efficiency.
With enough churn ZFS will eventually balance out the data since
re-flow happens naturally over time due to copy-on-write[^4],
but my workload is archival and low-churn so this won't happen effectively.

The parity level of a RAID-Z vdev cannot be changed after creation.

Having a RAID-Z vdev in a pool prevents any vdev from being removed from the pool[^1].

One way to increase pool capacity is to add a vdev.
Following rules of thumb from above, the vdev should be identical to existing vdevs.
Mirror vdevs allow capacity to be increased in smaller increments since they are
made of 2 or 3 devices, while RAID-Z vdevs usually have between 3 and 12 devices.

Another way to increase pool capacity is to replace all drives in a vdev with
new drives of higher capacity: ZFS will automatically find and make use of the new capacity.
Each drive replaced needs a resilver, so this quickly becomes unreasonable for large RAID-Z vdevs.
Mirror vdevs again allow capacity to be increased in small increments because they are smaller.

Mirror vdevs are much more flexible than RAID-Z vdevs.

## Comparison


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

https://www.truenas.com/docs/references/zfsprimer/
https://forums.freebsd.org/threads/zpool-degraded-state.64073/
https://blocksandfiles.com/2022/06/20/resilvering/
