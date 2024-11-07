# 16. Use Restic to create and manage cloud backups to Backblaze B2

## Goals

- Cheap cloud storage (amount and ingress/egress fees)
- Reliable cloud storage
- Immutable

## Options

- [Poli Systems](https://polisystems.ch/en/s3)
- [Backblaze B2](https://www.backblaze.com/cloud-storage)
- [AWS S3 Glacier](https://aws.amazon.com/s3/storage-classes/glacier/)
- [Wasabi](https://wasabi.com/)
- [rsync.net](https://rsync.net/)

## Decision

Upload backups to Backblaze B2

## Side effects

I will pay for B2 storage costs.

I will pay for some egress costs, as restic pulls some data down for deduplication.

All the good things backups provide.

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

Other options are [duplicacy](https://duplicacy.com/) and [kopia](https://kopia.io/).


