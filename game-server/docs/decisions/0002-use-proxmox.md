# 2. Use Proxmox as the operating system

Date: 2023-12-13

## Status

Accepted

## Context

I have had good experiences running services in containers.
I appreciate the freedom provided by the portable, immutable, and disposable nature of containers.
I also like the self-documenting and reproducible way that containers are built.
I am curious about using virtual machines and something like [Packer](https://www.packer.io/) to get similar benefits at the OS layer.

There appear to be a lot of distributions of Linux with support for running virtual machines.
Proxmox is distro focused on running virtual machines, and seems to be well-loved and have a large community.
My friend uses Proxmox for their homelab and likes it.

I find that trying something out is the best way to learn.

## Decision

Use Proxmox as the host OS.

## Consequences

I will learn how to use Proxmox.

Proxmox will provide first-class support for running and managing VMs.
This will give me the opportunity to explore tools like Packer.

Using VMs will add a layer of complexity over running things on bare metal.
