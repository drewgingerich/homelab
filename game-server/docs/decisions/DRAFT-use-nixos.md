# 2. Use NixOS

## Problem

I want to control the state of my operating system and programs,
so I can be confident about what's running and how it's configured, and
be able to recreate the system if necessary.

The state of my user data is out of scope here: it's handled separately by backups.

This breaks down into a couple of goals:

1. Define system state completely and explicitly
2. Reproduce system state in a robust fashion
3. Prevent system state drift

All of these qualities together add up to system that is always in the state I expect,
and can be recreated with confidence if necessary.

## Options

- Traditional package manager
- Provisioning tool
- Atomic Linux
- NixOS

## Solution

Use NixOS.

## Side effects

I need to learn how to configure NixOS,
which also involves learning the Nix language and Nix packaging ecosystem.

## Exploration

### Traditional package manager

Standard package managers such as [APT](<https://en.wikipedia.org/wiki/APT_(software)>) and [DNF](<https://en.wikipedia.org/wiki/DNF_(software)>)
can install desired packages to bring a system to a desired state.
There are a few downsides to traditional package managers, though.

First is that they are non-deterministic. While they will install the requested package, the version and sub-dependency versions
may change depending on installation order and time.

Most package managers do not fully manage state, for example, and can leave cruft behind after upgrades and uninstalls.
This means that while provisioning tools are effective at getting the system working, compliance with the target state is only superficial:
the system state to only brought to match the pieces of state explicitly specified in the target state.
Exact versions of sub-dependencies or extra cruft files are permitted, for example.
This means some state remains unmanaged.

### Provisioning tool

Provisioning tools bring a system to a specified state.

[Ansible](https://www.ansible.com/) seems to be the most popular provisioning tool today.

Provisioning tools use other tools such as package managers to reach the target system state.
This means they inherit the downsides of these underlying tools, and don't satisfy what I'm looking for.

### Atomic Linux

[Atomic Linux](https://github.com/Malix-Labs/Awesome-Atomic) (FKA Immutable Linux) are
Linux distributions with a read-only core OS and atomic updates.
Together, these mean the core OS is always in a well-defined state, cannot drift,
and is clearly separated from user configuration.

The technology and implementation behind immutability and atomicity varies by distribution.
[Universal Blue](<https://en.wikipedia.org/wiki/DNF_(software)>) seems to be the most popular series of Atomic distros right now,
and provides system state with images using [rpm-ostree](https://github.com/coreos/rpm-ostree).

Atomic Linux distros generally provide some way to customize the core OS,
such as Containerfiles for creating custom OS images, or filesystem overlays.

https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/

Atomic Linux is often paired with things like [Flatpak](https://flatpak.org/)
and [distrobox](https://distrobox.it/) for isolated user apps and configuration.

There are immutable distributions catering specifically to gaming,
such as [Bazzite](https://bazzite.gg/) and [ChimeraOS](https://chimeraos.org/),

The main downside of Atomic Linux appears to be that core OS configuration can be
clunky, limited (e.g. the desktop manager can't be changed), and relies on tradition package managers.
This means that while Atomic Linux presents great management, reproducibility, and drift resistance of OS state
once it's frozen, getting there still involves the pitfalls of traditional package managers.
It feels like a really excellent band-aid.

- [Understanding Immutable Linux OS: Benefits, Architecture, and Challenges](https://kairos.io/blog/2023/03/22/understanding-immutable-linux-os-benefits-architecture-and-challenges/)
- ["Immutable" → reprovisionable, anti-hysteresis](https://blog.verbum.org/2020/08/22/immutable-%e2%86%92-reprovisionable-anti-hysteresis/)
- [Awesome Atomic](https://github.com/Malix-Labs/awesome_atomic)
- https://www.reddit.com/r/linuxmasterrace/comments/19dvi74/looking_at_you_nixos/
- https://www.reddit.com/r/linuxmasterrace/comments/19dvi74/comment/kje2edw/

### NixOS

[NixOS](https://nixos.org/)

NixOS provides excellent management, reproducibility, and drift resistence of OS state
because it's built on top of the Nix package manager,
which provides isolated, read-only, reproducible package installations.

Because NixOS provides these qualities from the ground up,
instead of only when freezing a known-good state,
it is much more friendly to tinkering.
E.g. when installing a package, I don't have to worry about generating cruft,
dependency conflicts, or non-deterministic sub-dependencies.
Custom changes are also first-class citizens: I don't have to overlay them over a base OS image
or use tools like Flatpak to isolate them.

[Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS) is a NixOS configuration tailored to gaming.
This is a cool project, but I also like to set things up myself so I understand them.
Because of this, I'm mostly interested in Jovian NixOS as a reference for my own configuration.
