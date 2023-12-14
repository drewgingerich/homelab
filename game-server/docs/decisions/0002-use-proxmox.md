# 2. Use Proxmox as the operating system

Date: 2023-12-13

## Status

Accepted

## Context

I have had good experiences running services in containers.
I appreciate the freedom provided by the portable and disposable nature of containers,
yielded by the self-documenting and reproducible way in which containers are built,
and by treating them as immutable infrastructure.
I am curious about using virtual machines to get similar benefits at the OS layer.

There appear to be a lot of distributions of Linux with support for running virtual machines.
Proxmox is distro focused on running virtual machines, and seems to be well-loved and have a large community.
My friend uses Proxmox for their homelab and likes it.

I find that trying something out is the best way to learn.

## Decision

Use Proxmox as the host OS.

## Consequences

I will learn how to use Proxmox.

Using VMs may give me a reproducable and self-documenting way to provision my computer,
and let me treat the
It also may allow me to treat my computer as immutable infrastructure.

Using VMs will add a layer of complexity over running things on bare metal.
