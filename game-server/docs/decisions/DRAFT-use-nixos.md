# 2. Use NixOS

## Problem

I get uneasy when I don't know the state of my system.
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

- Ansible
- Packer
- Atomic Linux distro
- NixOS

## Solution

Use NixOS.

## Side effects

I need to learn how to configure NixOS,
which also involves learning the Nix language and Nix packaging ecosystem.

## Exploration

### Provisioning tools

The top contenders I know of are:

- [Ansible](https://www.ansible.com/)
- [CloudInit](https://cloud-init.io/)
- [Packer](https://developer.hashicorp.com/packer)

These tools work in different ways, but the end result is similar:
they bring the system to a desired state.

All three use configuration files that can be version controlled.
Ansible's configuration is declarative, while CloudInit and Packer use Bash (similar to a Dockerfile).

### Immutable Linux distributions

[Atomic Linux](https://github.com/Malix-Labs/Awesome-Atomic) (FKA Immutable Linux) are 
Linux distributions with a read-only core OS and atomic updates.
Together, these mean the core OS is always in a well-defined state, cannot drift,
and is clearly separated from user configuration.

The technology and implementation of immutability and atomicity varies by distribution.

[rpm-ostree](https://github.com/coreos/rpm-ostree) seems to be the most popular right now.
https://universal-blue.org/
https://www.reddit.com/r/linuxmasterrace/comments/19dvi74/looking_at_you_nixos/

Immutable distros usually provide some way to customize core OS configuration,
such as filesystem overlays.

Immutable Linux is often paired with things like [Flatpak](https://flatpak.org/)
and [distrobox](https://distrobox.it/) for user apps and configuration.

Two popular immutable distributions are [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)
and [openSUSE MicroOS](https://microos.opensuse.org/).

https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/

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

https://www.reddit.com/r/linuxmasterrace/comments/19dvi74/comment/kje2edw/

### NixOS

[NixOS](https://nixos.org/)

I am a big fan of configuration as code
I can treat my system configuration as disposable, since it can be recreated from the NixOS configuration.

### Jovian NixOS

[Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS) is a NixOS configuration tailored to gaming.

This is a cool project, but I also like to set things up myself so I understand them.

## References

- [Understanding Immutable Linux OS: Benefits, Architecture, and Challenges](https://kairos.io/blog/2023/03/22/understanding-immutable-linux-os-benefits-architecture-and-challenges/)
- [Awesome Atomic](https://github.com/Malix-Labs/awesome_atomic)
- https://github.com/Jovian-Experiments/Jovian-NixOS
