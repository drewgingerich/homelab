# 4. Use ZFS for the server filesystem

Date: 2019

## Status

Accepted

## Context

I have enough media that I need a way to store data across multiple disks.
I also want the ability to add more disks to the storage pool in the future, in case I run out of storage.

My server will be used for long-term storage, so disk failure and bitrot could become issues.
I want a filesystem that can provide some data redundancy to help mitigate data loss form disk failure,
and that can prevent bitrot.

## Decision

I will use ZFS as the filesystem for storing data.

## Consequences

ZFS allows me to group multiple disks into a single virtual device.

ZFS protects against bitrot of data at rest.
I should use ECC RAM to help prevent in-memory bitrot and avoid undermining the protection ZFS provides.

I should follow the rule of thumb and get about 1G of RAM per TB of storage in my ZFS pool.

I gain access to other features of ZFS, including snapshots, compression, and encryption.

Using ZFS introduces additional complexity to the system that I will need to manage.
I will need to become familiar with how ZFS works.
I will need to perform regular maintainence, such as taking and pruning snapshots and monitoring reported errors.

## References

- [ZFS 101—Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/)
