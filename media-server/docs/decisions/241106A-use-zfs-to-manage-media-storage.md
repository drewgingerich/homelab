# Use ZFS to manage media storage

## Goals

- Store terabytes of data across multiple storage devices
- Ensure integrity of stored data

## Options

- [ZFS](https://en.wikipedia.org/wiki/ZFS)
- [BTRFS](https://en.wikipedia.org/wiki/Btrfs)
- [mdadm](https://en.wikipedia.org/wiki/Mdadm) + [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)) + [XFS](https://en.wikipedia.org/wiki/XFS)
- [Hardware RAID controller](https://en.wikipedia.org/wiki/RAID#Hardware-based) 

## Decision

I will continue to use ZFS to store data.

## Side effects

I don't have to do anything right now, since I'm already using ZFS!

I get ZFS features such as snapshots and tunable datasets.

I should continue to use ECC RAM to complement ZFS's data integrity features.

I should also follow the rule of thumb and get about 1G of RAM per TB of storage in my ZFS pool.

There's a lot more I can learn about ZFS,
so for better and for worse I'm opting into another area of learning.
I have heard that naive use of ZFS can lead to poor outcomes,
and I could very well be in this bucket without realizing.

## Context

I have already been using ZFS to manage my media server's storage for several years,
and it's been working well for me.

ZFS is a holistic storage solution, providing filesystems as well as physical device management.
This approach gives ZFS a lot of power and flexibility.

In particular, ZFS allows me to store data across multiple devices with redundancy,
automatically repairs data errors by keeping checksums,
and provides quality of life features such as snapshots.
Also my more knowledgable friend uses it,
which means I have some support if I need it (or at least commiseration).

I am mainly writing this decision record to get my use of ZFS in writing.
Still, there are some other options that I want to note.

BTRFS is another holistic storage solution and provides many of the same features as ZFS.
While it has been included in the Linux kernel, BTRFS currently seems less mature
and is something I want to keep an eye on but not use right now.

An alternative to a holistic storage solution is to manage different layers of the storage stack with more specialized softwares.
This is how it has been done historically.
A common stack I've seen is `mdadm` for software RAID to store data across multiple devices,
`lvm` to create partitions,
and `xfs` to provide a filesystem.
I like the philosphy of using the specific tools for specific job,
but my (limited) understanding is that solutions like ZFS can leverage their holistic nature to
provide cool features that would otherwise be difficult to implement.
It also feels simpler to use just one thing to manage storage, and simplicity is important to me.

Hardware RAID controllers present an alternative to software RAID solutions like `mdadm`.
They allow systems without quality software RAID solutions (like Windows, historically) to use RAID.
They can also be faster because they use dedicated hardware tailored to the task.
As a downside, they seem to often be proprietary black-boxes that are difficult to troubleshoot and recover from when they fail.
They're also an extra thing to buy!

## References

- [ZFS 101—Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/)

