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
- Version-controlled

## Options

- Configuration management tool
- Immutable Linux distribution
- NixOS

## Solution

Use NixOS.

## Side effects

I need to learn how to configure NixOS,
which also involves learning the Nix language and Nix packaging ecosystem.

## Exploration

### Configuration management tools

Configuration management tools is a pretty general term,
but here I'm particularly talking about tools that help declaratively configure a Linux system.
The top contenders I know of are:

- [Ansible](https://www.ansible.com/)
- [CloudInit](https://cloud-init.io/)
- [Containerfile](https://github.com/containers/common/blob/main/docs/Containerfile.5.md)
- [Packer](https://developer.hashicorp.com/packer)

These tools work in different ways, but the end result is similar:
they bring the target system to a desired state based on a declarative configuration file.

### Immutable Linux distributions

[Immutable Linux](https://github.com/Malix-Labs/Awesome-Atomic) refers to
a Linux distribution with a read-only core OS and atomic updates.
These two qualities together mean the core OS is always in a well-defined state, cannot drift,
and is clearly separated from user configuration.

The technology and implementation of immutability and atomicity varies by distribution.

Customization is done using things like [Flatpak](https://flatpak.org/) for apps,
and [distrobox](https://distrobox.it/) for CLI tools.
Immutable distros usually provide some way to customize core OS configuration as well,
such as filesystem overlays.

Two popular immutable distributions are [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)
and [openSUSE MicroOS](https://microos.opensuse.org/).

There are also immutable distributions catering specifically to gaming,
such as [Bazzite](https://bazzite.gg/) and [ChimeraOS](https://chimeraos.org/),

The main downside of immutable Linux appears to be that core OS configuration can be
clunky and limited (e.g. the desktop manager can't be changed).
I don't think this is inherent to the general approach, though.
Updates generally require a full system reboot, which can make tinkering slow.

While immutable Linux provides fixed, known-good snapshots of the core OS,
the creation and customization of these snapshots still rely on non-deterministic package
managers like [APT](https://en.wikipedia.org/wiki/APT_(software)).
In practice it seems this works totally fine, but it naggles at me that we need immutable Linux
to compensate for the shortcomings of these package managers.

### NixOS

- [NixOS](https://nixos.org/)
- [Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)

I am a big fan of configuration as code
I can treat my system configuration as disposable, since it can be recreated from the NixOS configuration.


## References

- [Understanding Immutable Linux OS: Benefits, Architecture, and Challenges](https://kairos.io/blog/2023/03/22/understanding-immutable-linux-os-benefits-architecture-and-challenges/)
- [Awesome Atomic](https://github.com/Malix-Labs/awesome_atomic)
- https://github.com/Jovian-Experiments/Jovian-NixOS
