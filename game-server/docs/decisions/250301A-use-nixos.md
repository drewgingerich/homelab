# 2. Use NixOS

## Problem

I want to control the state of my operating system and programs,
so I can be confident about what's running and how it's configured, and
be able to recreate the system if necessary.

The state of my user data is out of scope here: it's handled separately by backups.

This breaks down into a couple of goals:

1. Define system state in a version-controlled configuration file
2. Define system state completely and explicitly
3. Reproduce system state in a robust fashion
4. Prevent system state drift

All of these qualities together add up to system that is always in the state I expect,
defined in a configuration file I can easily work on and reference,
and can be recreated with little hassle.

## Options

- Traditional package manager
- Provisioning tool
- Atomic Linux
- NixOS

## Solution

Use NixOS.

## Side effects

My system's OS state will be:

1. In a version-controlled configuration file
2. Defined completely and explicitly
3. Reproducible
4. Immune to drift

I need to learn how to configure NixOS,
which also involves learning the Nix language and Nix packaging ecosystem.

## Exploration

### Traditional package manager

Standard package managers such as [APT](<https://en.wikipedia.org/wiki/APT_(software)>) and [DNF](<https://en.wikipedia.org/wiki/DNF_(software)>)
can install desired packages to bring a system to a desired state.
There are a few downsides to traditional package managers, though.

First is that they are non-deterministic.
While they will install the requested package, the version and sub-dependency versions
may change depending on installation order and time.

Most package managers do not fully manage state, and can leave cruft behind after upgrades and uninstalls.
This introduces the (inevitable) potential for drift.

They are also not generally designed around version-controllable configuration:
they are designed to be interacted with using imperative CLI commands.

Traditional package managers are the status quo I am trying to get away from.

### Provisioning tool

Provisioning tools bring a system to a specified state.

[Ansible](https://www.ansible.com/) seems to be the most popular provisioning tool today.

Provisioning tools generally use other tools such as package managers to reach the target system state.
This means they inherit the downsides of these underlying tools,

While I like that provisioning tools add version-controllable configuration to tools that otherwise wouldn't have it,
they still don't fulfill everything I'm looking for
because they generally don't completely manage state and do not give full reproducibility.

### Atomic Linux

[Atomic Linux](https://github.com/Malix-Labs/Awesome-Atomic) (FKA Immutable Linux) are
Linux distributions with a read-only core OS and atomic updates.
Together, these mean the core OS is always in a well-defined state, cannot drift,
and is clearly separated from user configuration.

- ["Immutable" → reprovisionable, anti-hysteresis](https://blog.verbum.org/2020/08/22/immutable-%e2%86%92-reprovisionable-anti-hysteresis/)
- [Understanding Immutable Linux OS: Benefits, Architecture, and Challenges](https://kairos.io/blog/2023/03/22/understanding-immutable-linux-os-benefits-architecture-and-challenges/)

The technology and implementation behind immutability and atomicity varies by distribution.
[Universal Blue](https://universal-blue.org/) seems to be the most popular series of Atomic distros right now,
and provides system state through images using [rpm-ostree](https://github.com/coreos/rpm-ostree).

Atomic Linux distros generally provide some way to customize the core OS,
such as Containerfiles for creating custom OS images, and filesystem overlays.

https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/

Atomic Linux is often paired with things like [Flatpak](https://flatpak.org/)
and [distrobox](https://distrobox.it/) for isolated user apps and configuration.

There are immutable distributions catering specifically to gaming,
such as [Bazzite](https://bazzite.gg/) and [ChimeraOS](https://chimeraos.org/),

The main downside of Atomic Linux I can see is that customizing the core OS state can be
clunky, limited (e.g. the desktop manager can't be changed), and still relies on tradition package managers.
This means that while Atomic Linux presents great management, reproducibility, and drift resistance of OS state
once it's frozen, getting there still involves the pitfalls of traditional package managers.

I really like the direction Atomic Linux distros are heading in.
I especially like Universal Blue's image-based strategy, as someone that uses and like Docker containers a lot.
Still, it feels like a band-aid to the underlying problem of non-determinism and unmanaged state from traditional package managers.

### NixOS

[NixOS](https://nixos.org/)

NixOS provides excellent management, reproducibility, and drift resistance of OS state
because it's built on top of the Nix package manager,
which provides isolated, read-only, reproducible package installations.

Because NixOS provides these qualities from the ground up,
it is much more friendly to tinkering:
I don't have to worry about generating cruft,
dependency conflicts, or non-deterministic sub-dependency versions.
Custom changes are first-class citizens, handled the same way as any other configuration in NixOS.

[Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS) is a NixOS configuration tailored to gaming,
specifically for the Steam Deck.
It's a cool project, but seems most useful to me personally as a reference.
