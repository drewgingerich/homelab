# 6. Use Packer to create VM images

Date: 2023-12-27

## Status

Pending

## Context

- Can't reproduce state. This makes it more difficult to work with. More anxiety.
- Uncontrolled state permutations. Makes it difficult to understand the state of the system. Hits hard when managming multiple systems.
- Stale and leftover state. Can surprise. Makes state more complicated than necessary.
- Multiple things operating on state. Can surprise. Makes it difficult to understand the state of the system.

Manual configuration leads to configuration drift and state that's difficult to understand and reproduce.
There are many possible combinations of kernel and package versions,
and
As a system is upgraded over time,
Over time, the exact state of a computer becomes unknown.
The operating system and package versions are not managed or deterministic.

Automated configuration management using something like Ansible improves on this,
but still leads towards configuration drift and unknown state.

Configuration drift can be fully remediated by reinstalling and reprovisioning.

## Decision

Use Packer to create VM images.

## Consequences
