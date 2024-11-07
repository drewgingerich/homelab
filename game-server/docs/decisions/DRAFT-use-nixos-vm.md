# 2. Use NixOS VM

## Problem

I get uneasy when I stop knowing the state of my system.
This can happen due to drift from e.g. package and OS upgrades,
cruft from dirty package uninstallations,
or me simply forgetting how I configured that one thing 4 years ago.

I want a way to bring the system to a well-known state.
I want this to derive from a version-controlled artifact
so that if my system dies I can reproduce it.

- No drift
- Reproducible
- Declarative
- Version-controlled.

## Options

- Immutable Linux + provisioning tool
    - [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)
    - [Bazzite](https://bazzite.gg/)
    - [ChimeraOS](https://chimeraos.org/)
    - [HoloISO](https://github.com/HoloISO)
- Provisioning tools
    - [Ansible](https://www.ansible.com/)
    - [CloudInit](https://cloud-init.io/)
    - [Containerfile](https://github.com/containers/common/blob/main/docs/Containerfile.5.md)
    - [Packer](https://developer.hashicorp.com/packer)
- NixOS
    - [NixOS](https://nixos.org/)
    - [Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)

## Solution

Use NixOS in order to have OS-level configuration as code.

## Side effects

I need to learn how to configure NixOs,
which also involves learning the Nix language and Nix packaging ecosystem.

## Context

I am a big fan of configuration as code
I can treat my system configuration as disposable, since it can be recreated from the NixOS configuration.


## References

- [Understanding Immutable Linux OS: Benefits, Architecture, and Challenges](https://kairos.io/blog/2023/03/22/understanding-immutable-linux-os-benefits-architecture-and-challenges/)
- [Awesome Atomic](https://github.com/Malix-Labs/awesome_atomic)
- https://github.com/Jovian-Experiments/Jovian-NixOS
