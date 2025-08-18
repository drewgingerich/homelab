# Use 2-way mirror vdevs to create a ZFS pool for media storage

Follows up [241106A - Use ZFS to manage media storage](media-server/docs/decisions/241106A-use-zfs-to-manage-media-storage.md)

## Challenge

Select a ZFS pool layout for storing media.

## Assessment summary

Mirror or RAID-Z vdevs are most suitable for media storage on a home server,
and in particular 2-way mirrors and raidz2.

Compared to a pool of raidz2 vdevs, a pool of 2-way mirror vdevs provides:

- More flexibility for modifying vdevs and the pool
- Storage capacity can be increased in smaller increments, benefiting from storage costs lowering over time
- Better read performance and comparable write performance across the pool
- Faster and less hazardous failure recovery
- Worse fault tolerance
- Worse storage efficiency

## Decision

Use a pool of 2-way mirror vdevs for media storage.

## Side effects

I don't have to change my existing pool layout :)

After reaching a few mirror vdevs (probably 3+),
I should consider adding a [hot spare](https://docs.oracle.com/cd/E19253-01/819-5461/gcvcw/index.html).

Self-reminder that _RAID is not a backup_!
I will need to have a backup strategy regardless of this decision.

## Assessment

A ZFS filesystem is built on top of a virtual storage pool (zpool),
which in turn is composed of virtual devices (vdevs).
Vdevs are an abstraction over the underlying storage devices,
and provide features similar to conventional RAID.

ZFS currently provides five types of vdevs for storage:

- File: use a file from an existing filesystem (mainly for testing)
- Single-device: use one drive, without redundancy
- Mirror: store an identicle copy of data on each multiple drives (~ RAID 1)
- RAID-Z: stripe data across multiple drives, along with parity bits (~ RAID 5/6)
- dRAID: advanced version of RAID-Z for very large arrays (60+ devices)

[OpenZFS Basic Concepts](https://openzfs.github.io/openzfs-docs/Basic%20Concepts/index.html)

[TrueNAS ZFS Primer](https://www.truenas.com/docs/references/zfsprimer/)

[OpenZFS: the final word in file systems](https://jro.io/truenas/openzfs/)

ZFS also provides a few utility vdev types (spare, cache, log, and special), but they are not relevant here.

### Error correction

Mirror and RAID-Z vdevs both provide the data redundancy needed to enable ZFS's automatic error correction.

### Fault tolerance

Fault tolerance is how many devices can fail before data is lost.

A mirror vdev with $`d` devices has a fault tolerance of $`d - 1`$,
e.g. a 3-way mirror has a fault tolerance of 2.

A RAID-Z vdev with $`d` devices and $`p` parity has a fault tolerance of $`p`$,
e.g. raidz2 has a fault tolerance of 2 regardless of the number of disks in the vdev.

Mirror and RAID-Z vdevs can both have excellent fault tolerance.

Note that ZFS provides fault tolerance at the vdev level, not the zpool level,
and the robustness of the pool is hence limited by the weakest vdev.

> [!tip]
> Use vdevs with the same fault tolerance when creating a zpool.

Good backups are still the best way to prevent data loss,
and I look at fault tolerance as a convenience rather than a protection.

### Storage efficiency

Storage efficiency is how much of the total drive capacity can actually be used to store data.

A mirror vdev with $`d` devices has a storage efficiency of $`1 / d`$.
E.g. efficiency of a 2-way mirror is 50%, and a 3-way mirror is 33%.

The storage efficiency of a mirror plummets as redundancy goes up,
making a 2-way mirror the only reasonable mirror for most home data.

A RAID-Z vdev with $`d` devices and $`p` parity has a storage efficiency of $`d - p / d`$.
Increasing the number of devices in the vdev (referred to as _width_) increases efficiency,
while increasing parity lowers efficiency.
E.g. efficiency of a 3-wide raidz1 is 66%, a 4-wide raidz2 is 50%, and a 10-wide raidz3 is 70%.

RAID-Z practically always provides better storage efficiency than a mirror.

ZFS treats all devices in a vdev as having the same capacity as the smallest device in that vdev,
so using devices of unequal size will waste the extra space on the larger devices.

> [!tip]
> Use devices of equal capacity when creating a vdev.

I want good storage efficiency, of course,
but since I'm only making a small storage server it's also not my top priority.

> [!tip]
> There are tools for calculating the store efficiency of various pool layouts, check 'em out!
>
> - [OpenZFS Capacity Calculator](https://jro.io/capacity/)
> - [TrueNAS ZFS Capacity Calculator](https://www.truenas.com/docs/references/zfscapacitycalculator/)

### Performance

Performance is how fast data can be read from or written to a storage device.

My use-case is to store media files like pictures, books, and videos,
so the primary workload will be reading large files.

Understanding storage performance starts with understanding (roughly) what happens during an IO process.
Since I'm using hard disk drives (HDDs) for storage, I'll specifically look at how HDDs work.

Two steps determine the amount of time an IO operation takes:

1. **Preparation**.
   The amount of time an HDD take to prepare for data transfer is known as the _response time_.
   It is mostly a result of having to mechanically position the head (_seek time_) and platter (_rotational latency_).
   The response time of a single IO operation can vary by orders of magnitude based on
   how far the mechanical parts must move, so people generally talk about the average response time.
2. **Transfer**.
   The speed at which an HDD can transfer data is known as the _throughput_.
   It is mostly determined how fast the platter spins and the density of bits on the platter.

[Wikipedia: Hard disk drive performance characteristics](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics)

[Getting The Hang Of IOPS](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=e6fb4a1b-fa13-4956-b763-8134185c0c0a&CommunityKey=63b01f30-d5eb-43c7-9232-72362b508207&tab=librarydocuments)

Typical average response time appears to be 10 - 20 ms for HDDs today,
and typical average throughput appears to be 100 - 300 MBs.
A WD Red 4TB drive, for example, has a response time of ~10 ms and throughput of ~250 MBs.

[WD Red Pro Product Brief](https://documents.westerndigital.com/content/dam/doc-library/en_us/assets/public/western-digital/product/internal-drives/wd-red-pro-hdd/product-brief-western-digital-wd-red-pro-hdd.pdf)

[WD Red 4tb HDD Review (WD40EFRX)](https://www.storagereview.com/review/wd-red-4tb-hdd-review-wd40efrx)

Sequential IO workloads such as reading large files are bottle-necked by throughput.
Consider the thought experiment of an HDD reading an infinite amount of contiguous data:
since the preparation step happens only once, the response time is negligible
and the speed at which data can be read depends only on the HDD's throughput.

Random IO workloads such as databases, on the other hand, are bottle-necked by response-time.
Consider the thought experiment of an HDD reading infinite files of zero size:
since no data is being transferred, throughput is not a factor
and the speed at which files can be read depends only on how fast the HDD can prepare to read the data.

_IOPS_ (IO operations per second) is the reciprocal of response time,
and is often used when talking about drive performance instead.

While the read and write operations of an HDD have similar response times and throughputs,
things get more complicated for arrays of HDDs like mirror and RAID-Z vdevs.

When writing to a mirror, the operation completes when the data has been written to every disk in the mirror.
Write throughput and IOPS are equal to the throughput and IOPS of the slowest device, and don't scale with array size.

When reading from a mirror, ZFS sends the operation to one of the devices.
Since each device has a full copy of the data, any are able to handle the request,
and the throughput and IOPS are that of the device handling the request.

When writing to a RAID-Z vdev, the data is striped across every device.
Since each device only needs to write a fraction of the data and can do so in parallel,
write throughput is equal to the sum of the throughputs of the data disks.
On the other hand, write IOPS end up equal to the slowest device
since each device needs to participate in every write operation.

When reading from a RAID-Z vdev, part of the data is read from each device.
For the same reasoning as for writes above,
read throughput is equal to the sum of the throughputs of the devices
and read IOPS is equal to the slowest device.

As a side note, RAID-Z also incurs some CPU load in order to calculate the parity bits.
Since CPU cycles are much much faster than storage IO,
I think this is a negligable factor for storage performance.

To summarize, assuming all devices in the vdevs are identical:

| Vdev type     | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ------------- | ---------------- | ---------- | --------------- | --------- |
| single        | $T_w$            | $I_w$      | $T_r$           | $I_r$     |
| 2-way mirror  | $T_w$            | $I_w$      | $T_r$           | $I_r$     |
| 6-wide raidz2 | $4T_w$           | $I_w$      | $4T_r$          | $I_r$     |

So raidz2 vdevs absolutely crush mirrors in throughput, and are even with them in IOPs.
Well, yes, but there's a lot more to the story.

The analysis above is for a single IO operation.
In reality, IO operations will often happen in parallel.

For RAID-Z vdevs, there's not a difference:
since all devices participate in every operation,
a RAID-Z vdev can only handle one operation at a time.

For mirrors, there are huge differences.
Regretably, only for read operations:
all devices of a mirror participate in every write request,
as with RAID-Z, so there's no ability to handle write operations in parallel.
On the other hand, mirrors can handle read operations in parallel,
since each devices has a full copy of the data.

Assuming there's enough IO activity to saturate the vdevs:

| Vdev type     | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ------------- | ---------------- | ---------- | --------------- | --------- |
| single        | $T_w$            | $I_w$      | $T_r$           | $I_r$     |
| 2-way mirror  | $T_w$            | $I_w$      | $2T_r$          | $2I_r$    |
| 6-wide raidz2 | $4T_w$           | $I_w$      | $4T_r$          | $I_r$     |

So RAID-Z still wins on throughput, though not quite as handily in read throughput,
but mirrors win in read IOPS.
This is already great for IOPs-sensitive workloads like a database.

Once again, though, the story continues!
Let's zoom out from looking at single vdevs,
and instead consider the whole pool.

A ZFS pool distributes data across all of its vdevs.
Read and write throughput is equal to the sum of the throughputs of the vdevs, similar to RAID-Z,
while read and write IOPS are equal to the slowest vdev.

> [!note]
> At the pool level, ZFS doesn't stripe data like RAID-Z,
> but rather distributes blocks of data across vdevs.
> ZFS takes into account vdev usage and capacity,
> and tries to keep operations and storage well distributed.

And here's where mirrors can get huge benefits:
for each RAID-Z vdev, there could be 2-6 times more mirror vdevs (depending on RAIDZ width and parity).
Consider a pool with 6 devices, laid out as 3 x 2-way mirrors or 1 x 6-wide raidz2:

| Pool layout       | Write throughput | Write IOPS | Read throughput | Read IOPS    |
| ----------------- | ---------------- | ---------- | --------------- | ------------ |
| 6 x single        | $6T_w$           | $I_w$      | $6T_r$          | $I_r$        |
| 3 x 2-way mirror  | $3 * (T_w)$      | $I_w$      | $3 * (2T_r)$    | $1 * (2I_r)$ |
| 1 x 6-wide raidz2 | $1 * (4T_w)$     | $I_w$      | $1 * (4T_r)$    | $1 * (I_r)$  |

When looking at a pool holistically,
mirror vdevs become competative in throughput, even pulling ahead for reads.
On top of this, they keep their edge in read IOPs.
This makes mirrors a great choice for any read-heavy workload, in terms of performance.

[iXsystems ZFS Storage Pool Layout White Paper](https://static.ixsystems.co/uploads/2020/09/ZFS_Storage_Pool_Layout_White_Paper_2020_WEB.pdf)

> [!note]
> While theory is great, actually measuring performance
> is the best way to find the optimal pool layout for a particular workload.
> Measuring takes effort, though, and I don't wanna; my server has been running fine.
> For folks who do want to be thorough, [fio](https://fio.readthedocs.io/en/latest/fio_doc.html) seems like a good tool.

### Failure recovery

I want recovering from a drive failure to be easy, fast, and low-stress.
I won't be in the mood to spend a lot of time troubleshooting when a drive fails,
and I want to be confident the recovery process works.

A vdev with redundancy can have a drive fail and continue to function.
This gives an opportunity to replace the failed drive before data must be restored from a backup.

When a faulty drive is replaced, ZFS will move data to the new device with an operation called a _resilver_.

> [!note]
> A resilver is the same operation as a _scrub_,
> a maintenence task that reads through all data in the pool to find and correct errors.

A resilver is an intensive operation for the devices in a vdev because
all the data must be read from the remaining devices and written to the new device.
This large amount of IO raises the chance of secondary failure during the resilver,
and if the vdev doesn't have more redundancy (e.g. 3-way mirror or raidz2) then data will be lost.

> [!note]
> There is a lot of discussion around how much redundancy is needed to be safe during a resilver.
> The fear is that that storage device capacity has grown so large that a second or third failure during resilver is inevitable.
> Empirically, things don't appear to be so dire.
>
> - [Why RAID 5 stops working in 2009](https://www.zdnet.com/article/why-raid-5-stops-working-in-2009/)
> - [Why RAID-5 Stops Working in 2009 - Not Necessarily](https://www.high-rely.com/2012/08/13/why-raid-5-stops-working-in-2009-not/)
> - [Reddit: Statistics on real-world Unrecoverable Read Error rate numbers](https://www.reddit.com/r/zfs/comments/3gpkm9/statistics_on_realworld_unrecoverable_read_error/)
> - [TrueNAS Forums: Assessing the Potential for Data Loss](https://www.truenas.com/community/resources/assessing-the-potential-for-data-loss.227/)
> - [Disk failures in the real world: What does an MTTF of 1,000,000 hours mean to you?](https://www.usenix.org/legacy/events/fast07/tech/schroeder/schroeder.pdf)
> - [Failure Trends in a Large Disk Drive Population](https://static.googleusercontent.com/media/research.google.com/en//archive/disk_failures.pdf)

> [!note]
> Unlike conventional RAID, the file-aware nature of ZFS means it can contain an error
> to just the associated file, and continue to successfuly read other files.
> Of course, a catastrophic device failure can still make the whole device unreadable.

In other words, the more data that must be read during a resilver,
the higher the odds of a secondary failure.

> [!tip]
> Smaller vdevs have a lower chance for secondary failure during a resilver.

Because RAID-Z vdevs are generally much larger than mirrors and additionally have parity bits,
the odds of a secondary failure during a resilver are higher for RAID-Z vdevs than for mirrors.

### Flexibility

Storage needs grow over time.
I take more pictures, but more TV and mustic, accumulate more data,
and my existing storage fills up.

[Hard Drive Cost Per Gigabyte]: https://www.backblaze.com/blog/hard-drive-cost-per-gigabyte/

On the other hand, storage gets cheaper over time.
Technology improves, and what was once an expensive, cutting edge 4TB device
is now relatively small and cheap.

It is nice to be able to ride cheapening storage costs by
incrememtally adding storage as needed.
The ZFS pool layout needs to allow for incremental growth to do so.

I'm also still learning, and appreciate flexibility so I don't inadvertently
back myself into a corner.

Mirror vdevs are very flexible.
Devices can be added or removed from a mirror vdev at any time without side-effects.
Of course, removing devices lowers the redundancy in the vdev.

RAID-Z vdevs are less flexible.
Devices can be added to a RAID-Z vdev, but adding a device will not immediatly improve the storage efficiency of existing data
because it is not rewritten to use the new device.
Storage efficiency will instead trend towards the new limit over time as existing data is updated.
For archival workloads, data will not often be update so the new limit will be reached slowly or never.

[ZFS: Read Me 1st](https://nex7.blogspot.com/2013/03/readme1st.html)

Devices cannot be removed from a RAID-Z vdev.
Since data is sriped across all devices in the vdev,
removing a device would necessitate re-writting all of the data in the vdev.

The parity level of a RAID-Z vdev also cannot be changed after creation.
This limits the usefulness of being able to add devices,
because parity should be raised as devices are added to maintain reasonable reliability for failure recovery,

Pool capacity can also be modified by adding or removing vdevs.

Having a RAID-Z vdev in a pool prevents any vdev from being removed from the pool,
while vdevs can be removed from a pool of all mirrors.

[Serverfault: Why doesn't ZFS vdev removal work when any raidz devices are in the pool?](https://serverfault.com/questions/1142074/why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool)

Following rules of thumb from above, any vdev to the pool should ideally be identical to the existing vdevs.
Since mirror vdevs are generally smaller (generally 2-3 devices) than RAID-Z vdevs (generally 3-12 devices),
a pool of mirror vdevs can be increased in smaller increaments.

Another way to increase pool capacity is to replace all drives in a vdev with
new drives of higher capacity, Ship of Theseus style.
ZFS is smart enough to will automatically find and make use of the new capacity once the capacity of all drives has been increased.
ZFS needs to resilver the vdev after each replaced drive,
which updating a RAID-Z vdev quickly becomes unreasonable as width increases.
The smaller size of mirror vdevs, on the other hand, means updating the is feasible,
and also again means capacity can be upgraded in smaller increments.

[ZFS: You should use mirror vdevs, not RAIDZ.](https://web.archive.org/web/20250729015305/https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/)
