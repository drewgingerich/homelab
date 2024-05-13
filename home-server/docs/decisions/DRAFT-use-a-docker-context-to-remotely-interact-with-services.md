# 13. Use a Docker context to remotely interact with services

Date: 2023-09-04

## Status

Accepted

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

## Decision

Use a Docker context to remotely interact with the media server over SSH.

## Consequences

This allows service configuration to be maintained on a convenient device such as my laptop, while dispatched to run on the media server.
This allows me to work on service configuration when the media server is not accessible over the network, such as when I have my laptop but no internet, though I still won't be able to deploy updates.

Sensitive files that are bind-mounted to a container must still be manually placed on the media server, using something like rsync.
Non-sensitive files can be provided by creating a custom Dockerfile, built on the desired image, and copying the files in.
