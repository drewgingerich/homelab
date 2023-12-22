# 2. Use LVM to manage storage

Date: 2023-12-21

## Status

Accepted

## Context

Proxmox can use ZFS or LVM to manage storage.
Proxmox defaults to LVM.

I currently use ZFS to manage storage on my media server.

ZFS provides data integrity for storage.
It is best paired with ECC RAM to complement this with data integrety for memory.
This system does not have ECC RAM.
I don't need high data integrety on this system, as I plan to back up data regularly
and I'm okay with downtime.

ZFS also provides a lot of features for optimizing storage performance.
I don't need these features as the SSD on this system should be fast and large enough for my current needs.

ZFS opportunistically uses a lot of RAM, though it will play well and reqlinquish RAM if other processes need to use it.
The general recommendation I've seen is to have 4 Gb + 1 Gb of memory per Tb of storage set aside for ZFS.
This system has 2 Tb of storage, so ideally 6 Gb of RAM should be set aside for ZFS.
I don't want to set aside so much RAM, though I don't have evidence my use-cases will need all 32 Gb of RAM this system has.

## Decision

Use LVM to manage storage.

## Consequences

I won't have the featureset or data integrity of ZFS.

I won't have the complexity or higher RAM usage of ZFS.

If I ever want to move to using ZFS, I will have to figure out how to migrate over from LVM.
From a cusory search this likely involves reinstalling Proxmox and restoring data from a backup,
which sounds fine to me.

I will need to learn how to use LVM.
