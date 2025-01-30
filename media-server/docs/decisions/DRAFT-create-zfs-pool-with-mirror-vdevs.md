# Create ZFS pool with 2-way mirror vdevs

## Relations

Follows up [241106 - Use ZFS to manage media storage](/media-server/docs/decisions/241106-use-zfs-to-manage-media-storage.md)

## Goal

Select ZFS pool layout for media storage.

## Options

1. 2-way mirror vdevs
2. 3-way mirror vdevs
3. Raidz1 vdevs
4. Raidz2 vdevs
5. Raidz3 vdevs

## Decision

Use a pool of 2-way mirror vdevs.

## Effects

Faster read throughput and IOPS than RAID-Z.

Slower write throughput than RAID-Z.

Less data transfer during resilvers than RAID-Z.

Less complex than RAID-Z.

More flexible than RAID-Z.
In particular, expanding storage only requires buying two new drives at a time.

No CPU load from calculating parity information.

50% storage efficiency, worse than RAID-Z.

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

### ZFS pool layout basics

A ZFS pool is a high-level abstraction that allows multiple
physical devices to be treated as one monolithic pool of storage.[^uz]

A ZFS storage pool is created out of one or more virtual devices (vdevs),
which is a lower-level abstraction over physical devices.
A vdev allows multiple devices to be treated as a single device with properties
depending on the type of vdev.

Many of ZFS' features, such as data redundancy and error correction,
are provided at the vdev level.

ZFS currently provides five types of vdev for storage:
file, single-device, mirror, [RAID-Z](raidz_docs), and [dRAID](draid_docs).

[raidz_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAID-Z.html
[draid_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/dRAID%20Howto.html

ZFS also provides a few utility vdev types: spare, cache, log, and special.
I am ignoring these for this assessment.

File vdevs use a file from an existing file system as a vdev.
They are primarily intended for testing and experimentation, and not real use.[^8]

Single-device vdevs store data on a single device (who'd have thought).
Since single-device vdevs provide no redundancy ZFS is not able to correct data errors.

A mirror vdev stores a redundant copy of data on each device in the vdev.
For example, a 3-way mirror vdev consists of three devices each with one copy of the data.

A RAID-Z vdev stripes data across the devices within the vdev,
along with parity bits to provide redundancy.
RAID-Z can use single, double, or triple parity,
referred to as raidz1, raidz2, and raidz3, respectively.

dRAID is an evolution of RAID-Z meant for very large arrays of devices, beyond what I'll ever use at home.

Out of all of these, mirrors and RAID-Z fit my use-case.

[TrueNAS: ZFS Primer](https://www.truenas.com/docs/references/zfsprimer/#zfs-self-healing-file-system)

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

Understanding storage performance starts with understanding (roughly) what happens during an IO process.
Since I'm using hard disk drives (HDDs) for storage, I'll specifically look at how HDDs work.

When reading data from a hard disk drive (HDD), the following process happens[^wp-hdd-access-time] [^wp-hdd-data-transfer-rate]:

1. IO command is processed by the HDD onboard controller (command processing time, ~1 us)
2. Head is moved into position (seek time, ~10 ms)
3. HDD waits for head to settle (settle time, ~0.1 ms)
4. HDD waits for platter to rotate into position (rotational latency, ~10 ms)
5. Head reads data into onboard disk buffer (media rate ~100 MiB/s)
6. Data is transferred from disk buffer to memory (~3 GiB/s)

The process is much the same for writes,
and for HDDs the speeds are also roughly the same.

[Wikipedia: Cylinder-head sector](https://en.wikipedia.org/wiki/Cylinder-head-sector)
[^wp-hdd-access-time]: [Wikipedia: Hard disk drive access time](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics#Access_time)
[^wp-hdd-data-transfer-rate]:
[Wikipedia: Hard disk drive data transfer rate](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics#Data_transfer_rate)
[Wikipedia: IOPS](https://en.wikipedia.org/wiki/IOPS)

To help figure out how this translates to performance under different workloads,
take two thought experiments.

First, consider reading an infinite amount of contiguous data.
The head only needs to be positioned once, so steps 1-4 only occur once and become negligible.
The transfer rate from disk buffer to memory is faster than the media rate, so it's not the bottleneck.
The dominant limitation is the media rate.
This situation represents the maximum data transfer rate, and the value is known as the _throughput_.
High throughput is good for sequential IO workloads, such as reading large files.

Second, consider reading files with zero size as fast as possible.
Since no data is being transferred, steps 5 and 6 are out of the equation
The dominant limitation is how long steps 1-4 take, collectively known as the _response time_ or _latency_.
Taking the reciprocal yields _IOPS_ (IO operations per second).
High IOPS is good for random IO workloads, such as databases.

[Getting the hang of IOPS](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=33141cc6-ef99-4dbb-b6dc-05e57706355b&CommunityKey=63b01f30-d5eb-43c7-9232-72362b508207&tab=librarydocuments)

My use-case is to store and consume media like pictures, books, and videos,
so the primary workload is sequential IO.

When getting into ZFS vdevs with multiple disks (or RAID in general),
read and write performances separate.

When writing to a mirror, the operation completes when the data has been
written to every drive in the mirror.
Write throughput is equal to the throughput of the slowest device.
Write IOPS is equal to the IOPS of the slowest device.
In other words, write IOPS and throughput are equivalent to a single disk and don't scale.

When reading from a mirror, ZFS can distribute operations between the devices.
For a single read, throughput is equal to the throughput of the assigned device.
For concurrent reads the throughput can be up to the sum of the throughputs of all the devices.
Read IOPS is equal to the sum of the IOPS of the devices.

When writing to a RAIDZ vdev, the data is striped across every device.
Since each device only needs to write a fraction of the data,
write throughput is equal to the sum of the throughputs of the data disks.
Write IOPS is equal to the slowest device.

When reading from a RAIDZ vdev, data must be read from every device.
For the same reason as writes, read throughput is equal to the
sum of the throughputs of the data disks.
Read IOPS is equal to the slowest device.

RAID-Z incurs some CPU load in order to calculate the parity bits,
but this is much faster than storage IO and is not a factor for throughput or IOPS.

To summarize, assuming all devices are identical:

| Vdev type     | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ------------- | ---------------- | ---------- | --------------- | --------- |
| Single        | $T_w$            | $I_w$      | $T_r$           | $I_r$     |
| 2-way Mirror  | $T_w$            | $I_w$      | $2 * T_r$       | $2 * T_r$ |
| 4-wide raidz2 | $4 * T_w$        | $T_w$      | $4 * T_r$       | $T_r$     |

A ZFS pool stripes data across all of its vdevs.
In this way it behaves similar to RAIDZ, but without penalties from parity bits.
Write throughput is equal to the sum of the throughputs of the vdevs,
and write IOPS is equal to the slowest vdev.
Read throughput is equal to the sum of the throughputs of the vdevs.
and read IOPS is equal to the slowest device.

An important consideration when comparing mirrors and RAIDZ:
for a set amount of disks, you might have something like 2 to 6 times
more vdevs when using mirrors (depending on RAIDZ width and parity).
While RAIDZ has better read and write throughput,
mirrors are competitive or better when considering the whole pool.

For a pool with 6 devices:

| Vdev type     | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ------------- | ---------------- | ---------- | --------------- | --------- |
| Single        | $6 * T_w$        | $I_w$      | $6 * T_r$       | $I_r$     |
| 2-way Mirror  | $3 * (T_w)$      | $I_w$      | $3 * (2 * T_r)$ | $2 * T_r$ |
| 4-wide raidz2 | $1 * (4 * T_w)$  | $T_w$      | $1 * (4 * T_r)$ | $T_r$     |

The 2-way mirror pool has 3/4 time the write throughput of the 4-wide raidz2 pool,
but 3/2 times the read throughput and 2 times the read IOPS.

The performance of a pool trends towards the average performances of its vdevs,
because ZFS distributes operations across the vdevs.
Having slow vdevs will undermine the performance of fast vdevs.
A rule of thumb is to use vdevs with similar performance,
most easily done use identical vdev and device types.[^6]

[Ars Technica: ZFS versus RAID](https://arstechnica.com/gadgets/2020/05/zfs-versus-raid-eight-ironwolf-disks-two-filesystems-one-winner/)
[Ars Technica: How fast are your disks? Find out the open source way, with fio](https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/)
[A Closer Look at ZFS, Vdevs and Performance](https://constantin.glez.de/2010/06/04/a-closer-look-zfs-vdevs-and-performance/)

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

[Reddit: Statistics on real-world Unrecoverable Read Error rate numbers ](https://www.reddit.com/r/zfs/comments/3gpkm9/statistics_on_realworld_unrecoverable_read_error/)
[TrueNAS forums: Assessing the Potential for Data Loss](https://www.truenas.com/community/resources/assessing-the-potential-for-data-loss.227/)
[NetApp Weighs In On Disks](https://storagemojo.com/2007/02/26/netapp-weighs-in-on-disks/)
[Why RAID 5 stops working in 2009](https://www.zdnet.com/article/why-raid-5-stops-working-in-2009/)
[Triple-Parity RAID and Beyond](https://queue.acm.org/detail.cfm?id=1670144)
[FreeBSD forums: Zpool Degraded state](https://forums.freebsd.org/threads/zpool-degraded-state.64073/)
[Blocks & Files: Resilvering](https://blocksandfiles.com/2022/06/20/resilvering/)
[Disk failures in the real world: What does an MTTF of 1,000,000 hours mean to you?](https://www.usenix.org/legacy/events/fast07/tech/schroeder/schroeder.pdf)
[Failure Trends in a Large Disk Drive Population](https://static.googleusercontent.com/media/research.google.com/en//archive/disk_failures.pdf)

### Flexibility

Storage needs grow over time, while storage gets cheaper over time[^10].
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

[^uz]: [ZFS 101—Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/)
[^1]: [serverfault: why doesn't ZFS vdev removal work when any raidz devices are in the pool?](https://serverfault.com/questions/1142074/why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool)
[^2]: [OpenZFS man pages: zpool-attach.8](https://openzfs.github.io/openzfs-docs/man/master/8/zpool-attach.8.html)
[^3]: [Wikipedia: parity bit](https://en.wikipedia.org/wiki/Parity_bit)
[^4]: [ZFS RAIDZ stripe width, or: How I Learned to Stop Worrying and Love RAIDZ](https://www.delphix.com/blog/zfs-raidz-stripe-width-or-how-i-learned-stop-worrying-and-love-raidz)
[^5]: [ZFS: Read Me 1st](http://nex7.blogspot.com/2013/03/readme1st.html)
[^6]: [OpenZFS: the final word in file systems](https://jro.io/truenas/openzfs/)
[^7]: [Reliable RAID Configuration Calculator (R2-C2)](https://jro.io/r2c2/)
[^8]: [Oracle ZFS admin guide: Using Files in a ZFS Storage Pool](https://docs.oracle.com/cd/E19253-01/819-5461/gazcr/index.html)
[^10]: [Hard Drive Cost Per Gigabyte](https://www.backblaze.com/blog/hard-drive-cost-per-gigabyte/)
[^use-mirrors-not-raidz]: [ZFS: You should use mirror vdevs, not RAID-Z.](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/)

[iXsystems ZFS storage pool layout white paper](https://static.ixsystems.co/uploads/2020/09/ZFS_Storage_Pool_Layout_White_Paper_2020_WEB.pdf)

[I had VDEV Layouts all WRONG! ...and you probably do too!](https://www.youtube.com/watch?v=_aACgNm8UCw)
