# User 2-way mirror vdevs to create a ZFS pool for media

Follows up [241106A - Use ZFS to manage media storage](media-server/docs/decisions/241106A-use-zfs-to-manage-media-storage.md)

## Challenge

Select a ZFS pool layout for storing media.

## Assessment summary

A pool consisting of mirror or RAID-Z vdevs is most suitable for media storage on a home server.

Compared to a pool of RAID-Z vdevs, a pool of mirror vdevs provides:

1. More flexibility for modifying the vdev and the pool
2. Storage capacity to be increased in smaller increments, benefiting from storage costs lowering over time
3. Better read performance and comparable write performance, at the level of the pool
4. Worse, but still comparable, fault tolerance
5. Faster and less hazardous failure recovery
6. Worse storage efficiency

## Decision

Use a pool of 2-way mirror vdevs for media storage.

## Side effects

I don't have to change my existing pool layout :)

After reaching a few mirror vdevs (probably 3+),
I should add a [hot spare](https://docs.oracle.com/cd/E19253-01/819-5461/gcvcw/index.html).

## Assessment

ZFS filesystems are built on top of virtual storage pools called zpools.

ZFS zpools are not directly composed from physical devices, like in conventional RAID,
but rather out of another abstraction: virtual devices (vdevs).

Vdevs present a consistent interface over varies underlying storage mediums,
and ZFS currently provides five types of vdev for storage:
file, single-device, mirror, [RAID-Z](raidz_docs), and [dRAID](draid_docs).

[raidz_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAID-Z.html
[draid_docs]: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/dRAID%20Howto.html

File vdevs present a file from an existing file system as a device,
intended for testing and experimentation.
[^oracle-zfs-admin-guide-using-files-in-a-zfs-storage-pool]

Single-device vdevs store data on a single device, providing no redundancy.

A mirror vdev provides redundancy by storing a copy of data on each device in the vdev.
E.g., a 3-way mirror vdev consists of three devices each with one copy of the data.

A RAID-Z vdev provides redundancy by striping data across the devices within the vdev along with [parity bits](https://en.wikipedia.org/wiki/Parity_bit).
RAID-Z can use single, double, or triple parity, referred to as raidz1, raidz2, and raidz3, respectively.

dRAID is an evolution of RAID-Z meant for very large arrays of devices (at least 60[^openzfs-understanding-zfs-vdev-types]).

I think that only mirror and RAID-Z vdevs are a good fit for my expected storage array size of 4 to 16 drives,
so I'll focus on just them from here on.

Side note: ZFS also provides a few utility vdev types (spare, cache, log, and special),
but I don't believe they're relevant here.

### Error correction

Mirror and RAID-Z vdevs both provide the data redundancy needed to enable ZFS's automatic error correction.
[^truenas-zfs-primer-zfs-self-healing-file-system]

### Fault tolerance

Fault tolerance is how many devices can fail before data is lost.

ZFS provides fault tolerance at the vdev level, not the zpool level.
The robustness of the pool is hence limited by the weakest vdev.
A rule of thumb is to create pools using vdevs with the same fault tolerance.

A mirror vdev with $`d` devices has a fault tolerance of $`d - 1`$,
e.g. a 3-way mirror has a fault tolerance of 2.

A RAID-Z vdev with $`d` devices and $`p` parity has a fault tolerance of $`p`$,
e.g. raidz2 has a fault tolerance of 2 regardless of the number of disks in the vdev.

Mirror and RAID-Z vdevs can both have excellent fault tolerance.

Having fault tolerance means a failed device won't result in lost data.
Good backups are the best way to prevent data loss,
but not having to restore from backup is a nice convenience that I'd appreciate.

### Storage efficiency

Storage efficiency is how much of the total drive capacity can actually be used to store data.

I want high storage efficiency, of course.

A mirror vdev with $`d` devices has a storage efficiency of $`1 / d`$.
E.g. efficiency of a 2-way mirror is 50%, and a 3-way mirror is 33%.

A RAID-Z vdev with $`d` devices and $`p` parity has a storage efficiency of $`d - p / d`$.
Increasing the number of devices in the vdev (referred to as _width_) increases efficiency,
while increasing parity lowers efficiency.
E.g. efficiency of a 3-wide raidz1 is 66%, a 4-wide raidz2 is 50%, and a 10-wide raidz3 is 70%.

RAID-Z always provides better storage efficiency than a mirror in practical usage.
In particular, the storage efficiency of a mirror plummets as redundancy goes up,
making a 2-way mirror the only reasonable mirror for most home data.

As a tangential note, ZFS treats all devices in a vdev as having the same capacity as the smallest device in that vdev.
Using devices of unequal size will waste the extra space on the larger devices,
so a rule of thumb is to match the capacity of all devices within a vdev.

I want good storage efficiency, of course,
but since I'm only making a small storage server it's also not my top priority.

#### Related

Shout out to the [OpenZFS Capacity Calculator](https://jro.io/capacity/).

### Performance

Performance is how fast data can be read from or written to a storage device.

My use-case is to store media files like pictures, books, and videos,
so the primary workload will be reading large files.

Understanding storage performance starts with understanding (roughly) what happens during an IO process.
Since I'm using hard disk drives (HDDs) for storage, I'll specifically look at how HDDs work.

There are two primary steps in an IO process that determine the amount of time it takes[^wikipedia-hard-disk-drive-performance-characteristics]:

1. The HDD prepares to transfer data. The amount of time this takes is known as the _response time_.
   The response time mostly comes from the mechanical movements of
   positioning the head (seek time) and platter (rotational latency).
   Note that the response time of a single IO operation can vary by orders of magnitude based on
   how far the mechanical parts must move, so it is the average response time that is discussed.
2. The HDD transfers data. The speed at which it can transfer data is known as the _throughput_.
   It is mainly limited by the transfer speed between the platter and onboard disk buffer.

For HDDs today, typical average response time appears to be 10 - 20 ms, and
typical average throughput appears to be 100 - 300 MBs.
A WD Red 4TB drive, for example, has a response time of ~10 ms and throughput of ~250 MBs.[^wd-red-pro-product-brief][^wd-red-4tb-hdd-review-(wd40efrx)]

Sequential IO workloads, e.g. reading large files, are bottle-necked by throughput,
To see why, consider reading an infinite amount of contiguous data:
since the preparation step happens only once, the response time is negligible
and the speed at which data can be read only depends on the HDD's throughput.

Random IO workloads, e.g. databases, are bottle-necked by response-time.
To see why, consider reading infinite files of zero size:
since no data is being transferred, throughput is not a factor
and the speed at which files can be read only depends on how fast the HDD can prepare to read the data.
Because it's awkward to talk about a value that's inversely proportional to speed,
people instead talk about the reciprocal of response time,
[_IOPS_](https//en.wikipedia.org/wiki/IOPS) (IO operations per second).[^getting-the-hang-of-iops].

So far, I haven't talked about differences in read and write operations.
HDDs read and write with similar response times and throughputs,
but things get more complicated for arrays of disks like mirror and RAID-Z vdevs.

When writing to a mirror, the operation completes when the data has been written to every disk in the mirror.
Write throughput and IOPS are equal to the throughput and IOPS of the slowest device, and don't scale with array size.

When reading from a mirror, ZFS distributes operations between the devices.
Since each device has a full copy of the data, it's able to independently respond to a read request
and the vdev as a whole can handle multiple read requests in parallel.
While a mirror vdev has the throughput of a single device for a single read request,
its throughput can rise to the sum of its device throughputs for concurrent reads.
For the same reasons, its read IOPS can rise to the sum of its device IOPS.

When writing to a RAID-Z vdev, the data is striped across every device.
Since each device only needs to write a fraction of the data,
write throughput is equal to the sum of the throughputs of the data disks.
On the other hand, write IOPS is equal to the slowest device because each device participates in every write operation.

When reading from a RAID-Z vdev, part of the data is read from each device.
For the same reasoning as for writes above,
read throughput is equal to the sum of the throughputs of the data disks
and read IOPS is equal to the slowest device.

As a side note, RAID-Z also incurs some CPU load in order to calculate the parity bits.
Since CPU cycles are much much faster than storage IO,
this is a negligable factor for storage performance.

To summarize, assuming all devices in the vdevs are identical:

| Vdev type     | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ------------- | ---------------- | ---------- | --------------- | --------- |
| single        | $T_w$            | $I_w$      | $T_r$           | $I_r$     |
| 2-way mirror  | $T_w$            | $I_w$      | $2 * T_r$       | $2 * T_r$ |
| 4-wide raidz2 | $4 * T_w$        | $T_w$      | $4 * T_r$       | $T_r$     |

So raidz2 performs better in everything except read IOPS.

Yes, BUT, the performance conversation doesn't end with vdevs!

A ZFS pool distributes data across all of its vdevs.
Similar to RAID-Z, this means read and write throughput is equal to the sum of the throughputs of the vdevs,
while read and write IOPS are equal to the slowest vdev.

> [!note]
> ZFS doesn't stripe data like RAID-Z, it just distributes blocks of data.
> Where ZFS places data is not deterministic because ZFS takes into account vdev usage and capacity,
> and tries to keep the operations and usage well distributed.

For each RAID-Z vdev, there could be 2-6 times more mirror vdevs,
depending on RAIDZ width and parity.
While a single RAID-Z vdev outperforms a single mirror vdev,
the picture is different when considering pool performance for a fixed number of devices.
E.g. for a pool with 6 devices:

| Pool layout       | Write throughput | Write IOPS | Read throughput | Read IOPS |
| ----------------- | ---------------- | ---------- | --------------- | --------- |
| 6 x single        | $6 * T_w$        | $I_w$      | $6 * T_r$       | $I_r$     |
| 3 x 2-way mirror  | $3 * (T_w)$      | $I_w$      | $3 * (2 * T_r)$ | $2 * T_r$ |
| 1 x 4-wide raidz2 | $1 * (4 * T_w)$  | $T_w$      | $1 * (4 * T_r)$ | $T_r$     |

When looking at a pool holistically,
mirror vdevs are actually better for read-heavy workloads
and are not too far behind for writes.

#### References

[^ixsystems-zfs-storage-pool-layout-white-paper]
[^ars-technica-zfs-versus-raid]
[^openzfs-the-final-word-in-file-systems]

Not as good:

[^ars-technica-how-fast-are-your-disks?-find-out-the-open-source-way,-with-fio]
[^a-closer-look-at-zfs,-vdevs-and-performance]
[^zfs-101—understanding-zfs-storage-and-performance]

### Failure recovery

I want recovering from a drive failure to be easy, fast, and low-stress.
I won't be in the mood to spend a lot of time troubleshooting when a drive fails,
and I want to be confident the recovery process works.

A vdev with redundancy can have a drive fail and continue to function.
This gives an opportunity to replace the failed drive before data must be restored from a backup.

When a faulty drive is replaced, ZFS will move data to the new device with an operation called a _resilver_.

> [!note]
> A resilver is actually the same operation as a _scrub_,
> which is a maintenence task that reads through the pool to find and correct errors.

A resilver is an intensive operation for the devices in a vdev because
all the data must be read from the remaining devices and written to the new device.
This intensity raises the chance of another device failing during the resilver.
If the vdev doesn't have enough redundancy to handle a second failure, then data will be lost.

> [!note]
> Unlike conventional RAID, the file-aware nature of ZFS means it can contain an error
> to just the associated file, and continue to successfuly read other files.
> Of course, a catastrophic device failure can still make the whole device unreadable.

The more data that must be read during a resilver,
the higher the odds of a second failure.
As a rule of thumb, smaller vdevs have more reliable resilvers.

The odds of a second failure during a resilver are higher for RAID-Z vdevs than for mirrors:

- RAID-Z vdevs are generally much larger than mirrors.
- RAID-Z vdevs musta dditional read parity bits during a resilver.

#### References

[^reddit-statistics-on-real-world-unrecoverable-read-error-rate-numbers-]
[^truenas-forums-assessing-the-potential-for-data-loss]
[^netapp-weighs-in-on-disks]
[^why-raid-5-stops-working-in-2009]
[^triple-parity-raid-and-beyond]
[^freebsd-forums-zpool-degraded-state]
[^blocks-&-files-resilvering]
[^disk-failures-in-the-real-world-what-does-an-mttf-of-1,000,000-hours-mean-to-you]
[^failure-trends-in-a-large-disk-drive-population]

### Flexibility

Storage needs grow over time.
I take more pictures, but more TV and mustic, accumulate more data,
and my existing storage fills up.

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

Devices cannot be removed from a RAID-Z vdev.
Since data is sriped across all devices in the vdev,
removing a device would necessitate re-writting all of the data in the vdev.

The parity level of a RAID-Z vdev also cannot be changed after creation.
This limits the usefulness of being able to add devices,
because parity should be raised as devices are added to maintain reasonable reliability for failure recovery,

Pool capacity can also be modified by adding or removing vdevs.

Having a RAID-Z vdev in a pool prevents any vdev from being removed from the pool,[^serverfault-why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool]
while vdevs can be removed from a pool of all mirrors.

Following rules of thumb from above, any vdev to the pool should ideally be identical to the existing vdevs.
Since mirror vdevs are generally smaller (generally 2-3 devices) than RAID-Z vdevs (generally 3-12 devices),
a pool of mirror vdevs can be increased in smaller increaments.

Another way to increase pool capacity is to replace all drives in a vdev with
new drives of higher capacity, like the Ship of Theseus.
ZFS is smart enough to will automatically find and make use of the new capacity once the capacity of all drives has been increased.
ZFS needs to resilver the vdev after each replaced drive,
which updating a RAID-Z vdev quickly becomes unreasonable as width increases.
The smaller size of mirror vdevs, on the other hand, means updating the is feasible,
and also again means capacity can be upgraded in smaller increments.

[^hard-drive-cost-per-gigabyte]: https//www.backblaze.com/blog/hard-drive-cost-per-gigabyte/

[^zfs-raidz-stripe-width-or-how-i-learned-to-stop-worrying-and-love-raidz]: https//www.delphix.com/blog/zfs-raidz-stripe-width-or-how-i-learned-stop-worrying-and-love-raidz

[^serverfault-why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool]: https//serverfault.com/questions/1142074/why-doesnt-zfs-vdev-removal-work-when-any-raidz-devices-are-in-the-pool

[^openzfs-man-pages-zpool-attach-8]: https//openzfs.github.io/openzfs-docs/man/master/8/zpool-attach.8.html

## Further Reading

[reliable-raid-configuration-calculator-(r2-c2)](https//jro.io/r2c2/)

[zfs-read-me-1st](http//nex7.blogspot.com/2013/03/readme1st.html)
[zfs-you-should-use-mirror-vdevs-not-raid-z](https//jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/)

[i-had-vdev-layouts-all-wrong-and-you-probably-do-too](https://www.youtube.com/watch?v=_aACgNm8UCw)
[switched-on-tech-design-zfs](https//sotechdesign.com.au/zfs/)

---

[^openzfs-understanding-zfs-vdev-types]: https://klarasystems.com/articles/openzfs-understanding-zfs-vdev-types/

[^openzfs-capacity-calculator]: https://jro.io/capacity/

[^truenas-zfs-primer-zfs-self-healing-file-system]: https://www.truenas.com/docs/references/zfsprimer/#zfs-self-healing-file-system

[^oracle-zfs-admin-guide-using-files-in-a-zfs-storage-pool]: https://docs.oracle.com/cd/E19253-01/819-5461/gazcr/index.html

[^choosing-the-right-zfs-pool-layout]: https://klarasystems.com/articles/choosing-the-right-zfs-pool-layout/

[^reddit-statistics-on-real-world-unrecoverable-read-error-rate-numbers-]: https//www.reddit.com/r/zfs/comments/3gpkm9/statistics_on_realworld_unrecoverable_read_error/

[^truenas-forums-assessing-the-potential-for-data-loss]: https//www.truenas.com/community/resources/assessing-the-potential-for-data-loss.227/

[^netapp-weighs-in-on-disks]: https//storagemojo.com/2007/02/26/netapp-weighs-in-on-disks/

[^why-raid-5-stops-working-in-2009]: https//www.zdnet.com/article/why-raid-5-stops-working-in-2009/

[^triple-parity-raid-and-beyond]: https//queue.acm.org/detail.cfm?id=1670144

[^freebsd-forums-zpool-degraded-state]: https//forums.freebsd.org/threads/zpool-degraded-state.64073/

[^blocks-&-files-resilvering]: https//blocksandfiles.com/2022/06/20/resilvering/

[^disk-failures-in-the-real-world-what-does-an-mttf-of-1,000,000-hours-mean-to-you]: https//www.usenix.org/legacy/events/fast07/tech/schroeder/schroeder.pdf

[^failure-trends-in-a-large-disk-drive-population]: https//static.googleusercontent.com/media/research.google.com/en//archive/disk_failures.pdf

[^ixsystems-zfs-storage-pool-layout-white-paper]: https//static.ixsystems.co/uploads/2020/09/ZFS_Storage_Pool_Layout_White_Paper_2020_WEB.pdf

[^ars-technica-zfs-versus-raid]: https//arstechnica.com/gadgets/2020/05/zfs-versus-raid-eight-ironwolf-disks-two-filesystems-one-winner/

[^openzfs-the-final-word-in-file-systems]: https//jro.io/truenas/openzfs/

[^getting-the-hang-of-iops]: https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=e6fb4a1b-fa13-4956-b763-8134185c0c0a&CommunityKey=63b01f30-d5eb-43c7-9232-72362b508207&tab=librarydocuments

[^ars-technica-how-fast-are-your-disks?-find-out-the-open-source-way,-with-fio]: https//arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/

[^a-closer-look-at-zfs,-vdevs-and-performance]: https//constantin.glez.de/2010/06/04/a-closer-look-zfs-vdevs-and-performance/

[^zfs-101—understanding-zfs-storage-and-performance]: https//arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/

[^wd-red-pro-product-brief]: https//documents.westerndigital.com/content/dam/doc-library/en_us/assets/public/western-digital/product/internal-drives/wd-red-pro-hdd/product-brief-western-digital-wd-red-pro-hdd.pdf

[^wd-red-4tb-hdd-review-(wd40efrx)]: https//www.storagereview.com/review/wd-red-4tb-hdd-review-wd40efrx

[^wikipedia-hard-disk-drive-performance-characteristics]: https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics
