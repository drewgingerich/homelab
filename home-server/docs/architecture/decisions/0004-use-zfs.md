# 4. Use ZFS

Date: 2019

## Status

Accepted

## Context

I have enough media that I need a way to store data across multiple disks.
I also want the ability to add more disks to the storage pool in the future, in case I run out of storage.

My server will be used for long-term storage, so disk failure and data degredation could become issues.

Hardware RAID controllers can be used to create single logical volumes from multiple physical disks.

ZFS seems cool, and my more knowledgable friend uses it.

## Decision

I will use ZFS as the filesystem for storing data.

## Consequences

ZFS can create a single filesystem using multiple disks.

ZFS protects against degredation of data at rest.
It does not protect against degredation of data in memory.
I should use ECC RAM to help prevent in-memory bitrot and avoid undermining the protection ZFS provides.

I should follow the rule of thumb and get about 1G of RAM per TB of storage in my ZFS pool.

I gain access to other features of ZFS, including snapshots, compression, and encryption.

Using ZFS introduces additional complexity to the system that I will need to manage.
I will need to become familiar with how ZFS works.
I will need to perform regular maintainence, such as taking and pruning snapshots and monitoring reported errors.

## References

- [ZFS 101—Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/)
