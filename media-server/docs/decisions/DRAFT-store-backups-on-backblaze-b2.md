# 16. Use Restic to create and manage cloud backups to Backblaze B2

Date: 2023-09-04

## Status

Accepted

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

Other options are [duplicacy](https://duplicacy.com/) and [kopia](https://kopia.io/).

## Decision

Use Restic to create and manage cloud backups to Backblaze B2.

## Consequences

I will pay for B2 storage costs.

I will pay for some egress costs, as restic pulls some data down for deduplication.

All the good things backups provide.
