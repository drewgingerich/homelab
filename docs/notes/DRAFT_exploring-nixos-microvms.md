---
tags:
  - 'scope:personal-laptop'
---

# Exploring NixOS microvms

I'm looking for a more NixOS-native alternative to Docker containers.

NixOS virtualization declaratively wraps OCI containers.
Could be a path forward.

NixOS containers look promising, but I was't able to get bind mounts working with private user namespacing.

[NixOS microvm](https://microvm-nix.github.io/microvm.nix/) is another option.

VMs seem to have better security than containers,
and I would like to get experience working with VMs.

There are three workflows for managing microvms using `microvm-nix`.

- Fully declarative: VMs are built and started as part of the host system.
  VM configuration is part of the host system NixOS configuration,
  similar to how nixos-containers are configured.
- Imperative
- Declarative deployment: VMs are built and configured separate from the host.
  VMs are configured using a provided flake (which could be the same flake as the host, or not).
  VMs are built and started only if they have not been before;
  management past first build is handled imperatively.


## Fully declarative workflow


This keeps all state together, which seems nice for e.g. coordinating networking configuration between VMs and the host.
Fully-declarative VMs are managed as a systemd service, and can be started and stopped as needed.
A downside of this coupling is that the VMs and host get updated together, which can be a lot of change to handle at once.
VMs can still use a different version of `nixpkgs` using flake inputs and/or overrides.

This coupling requires separate flakes to fully sever.
I'm planning to keep all VMs and the host in the same flake,
so I'll still need to rely on multiple `nixpkgs` versions and overrides
if I want to keep host and VM package versions separate.

Each declarative VM adds to the host closure,
which increases the build time.
This apparently can get especially bad when running 10+ VMs.


## Declarative deployment workflow

The declarative deployment workflow


## Resources

https://gist.github.com/nrdmn/7971be650919b112343b1cb2757a3fe6
https://www.youtube.com/watch?v=iGteDsnlCoY
https://zemdregon.github.io/nix-docs/09-nixos/services/microvms/#overview 
