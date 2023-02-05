# 3. Use ZFS for the server filesystem

Date: 2023-02-04

## Status

Accepted

## Context

I have enough media that I need a way to store data across multiple disks.
I also want the ability to add more disks to the storage pool in the future, in case I run out of storage.

This server will be used for long-term storage
I want a filesystem that can provide some data redundancy to help mitigate data loss form disk failure.
I also want a filesystem that can prevent bitrot.

## Decision

I will use ZFS as the filesystem for storing my media.

## Consequences

ZFS allows me to group multiple disks into a single virtual device.

ZFS protects against bitrot of data at rest.
I should use ECC RAM to help prevent in-memory bitrot.

I should use about 1G of RAM per TB of storage in my ZFS pool.

I gain access to other features of ZFS, including snapshots, compression, and encryption.

ZFS introduces additional complexity to the system that I will need to manage.
I will need to become familiar with how ZFS works.
I will need to perform regular maintainence, such as taking and pruning snapshots and monitoring reported errors.
