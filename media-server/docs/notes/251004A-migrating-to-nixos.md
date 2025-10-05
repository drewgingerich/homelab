# Migrating to NixOS

Now that [I've decided to install NixOS on my media server](/media-server/docs/decisions/251004A-use-nixos.md),
I want to make a plan to minimize downtime.
Some downtime is fine since this is just a personal thing,
mostly I don't want to stress over having my server in a nonfunctional state.

The things I need installed right away are:

- ZFS, for accessing my storage
- Docker, for running my services
- Tailscale, for remote access

The list is not long, a nice upside of using containers for running services.

A question I have is how to most quickly use my prepared NixOS configuration.
When I installed NixOS on my game server, the process was a bit awkward:

1. Install NixOS with default configuration
2. Enable flakes
3. Configure git + SSH key for GitHub
4. Pull my homelab Git repo down
5. Integrate the generated hardware configuration into my version-controlled config
6. Switch to my version-controlled config

Looking at my [notes on installing NixOS for my game server](/game-server/docs/notes/250308A-installing-nixos-on-bare-metal.md),
I see that installing from a flake is as simple as:

```sh
nixos-install --flake https://github.com/drewgingerich/homelab#unremarkable-game-server
```

This seems great, but I think there's a chicken and egg problem in that
the hardware configuration needs to be generated and included in the flake ahead of time.

It looks like I can do this by installing Nix on my existing system, and running:

```sh
nix-shell -p nixos-install-tools
nixos-generate-config
```

I also don't know how installing from a flake will handle the existing drive already being partitioned.

It seems like the NixOS installer won't do any partitioning.
I remember wiping and repartitioning the drive for my game server by hand.
[disko](https://github.com/nix-community/disko) appears to be a Nix project that can handle this declaratively,
but also feels like more than I'm ready to tackle right now.

https://tinkering.xyz/installing-nixos/

While looking around a bit, I see that NixOS can actually be installed on an existing Linux system in a few ways.

https://nixos.org/manual/nixos/stable/#sec-installing-from-other-distro

Using the `NIXOS_LUSTRATE`, NixOS can be installed over top of an existing Linux installation without the need for a bootable USB.
Let's give it a try.

## 1. Download Nix

```sh
curl -L https://nixos.org/nix/install | sh
```

Yes, I'm bad and just ran this.

This advised me it would do a single-user installation,
and gave me a URL for information on [how to do a multi-user installation](https://nix.dev/manual/nix/2.28/installation/installing-binary.html#multi-user-installation).
My understanding is that NixOS needs a multi-user installation,
so I did a `ctrl-c` and followed the link.
Based on those docs, I instead ran:

```sh
curl -L https://nixos.org/nix/install > nixos-installer.sh
bash nixos-installer.sh --daemon
```

## 2. Initial configuration

I copied over my configuration from my game server,
and stripped it down to set up some essentials,
in particular ZFS, SSH, Docker, and Tailscale:

```nix
  # ...
  environment.systemPackages = with pkgs; [
    docker
    git
    lshw
    tailscale
    vim
    zellij
  ];

  boot.zfs.enable = true;
  services.zfs.autoscrub.enable = true;

  services.openssh.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  # ...
```

## 3. Generating hardware config

```sh
nix-shell -p nixos-install-tools
sudo `which nixos-generate-config`
```

I used `rsync` to copy this file over to my laptop, to include in my flake.

The generated hardware config had a bunch of filesystem items for Docker containers and Snap packages.
I removed all of these.

After looking at the [NixOS ZFS docs](https://wiki.nixos.org/wiki/ZFS#Mount_datasets_at_boot) more,
I also removed the ZFS filesystem items so that NixOS wouldn't try to mount them using Systemd,
since the ZFS mount service should do this already and would conflict.

## 4. Enable Nix experimental features

```sh
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

## 5. Build the NixOS system closure

The next step is to build the system closure and create a Nix profile for it.
My understanding is that the profile is roughly a pointer that can be used to return to the configuration,
e.g. rolling back to an older generation.

The documentation doesn't demonstrate use of Nix flakes as a matter of policy,
so I need to figure out equivalent commands for flakes.
It looks like `nix build` has `--profile` flag to create a profile from a NixOS configuration.

https://discourse.nixos.org/t/managing-boot-entries-without-nix-env/46945

```sh
nix build --profile system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server
```

```
error: 'nixosConfigurations.dusty-media-server.type' is not a string but a set
```

Well huh. After looking around for a bit, I see that I actually need to target `nixosConfigurations.<hostname>.config.system.build.toplevel` attribute.

https://github.com/NixOS/nix/issues/8823#issuecomment-1743000172

```sh
nix build --profile system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

That appears to work, but I get a few errors.

Instead of having to commit and push from my laptop, then pull and run from my server,
I'd like to be able to test the build locally.

Rubbing my two brain cells together, I discover this is easy as running `nix build` from my local flake repo:

```sh
nix build .#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

This reaffirms the cool fact that a NixOS generation is just a Nix package.
It can be built anywhere a Nix package can be built,
and runs all the validation that the package includes.

Actually only sort of. After getting through a few syntax errors,
I'm hit with:

```
error: a 'x86_64-linux' with features {} is required to build '/nix/store/y32c04z2csh9n9adka4ky1g4l1irbl3d-NetworkManager.conf.drv', but I am a 'x86_64-darwin' with features {apple-virt, benchmark, big-parallel, nixos-test}
```

Makes sense, I guess.

Looking around, there are a few ways to solve this:

1. Use [a NixOS container](https://github.com/LnL7/nix-docker) to build the package
2. Configure Nix to [cross-compile the package](https://nixos.org/manual/nixpkgs/stable/#chap-cross)
3. Use my server as a [remote builder](https://nix.dev/manual/nix/2.18/advanced-topics/distributed-builds)

The third options sounds the most straightforward.
From the docs, the command looks like:

```sh
nix build .#nixosConfigurations.dusty-media-server.config.system.build.toplevel --builders ssh://media-server
```

I can use `ssh://media-server` because I have the user and IP set up in my SSH config file for the `media-server` server.

I get an error:

```
warning: ignoring the client-specified setting 'builders', because it is a restricted setting and you are not a trusted user
```

From the docs, it looks like I need to add my user to [the list of trusted users](https://nix.dev/manual/nix/2.28/command-ref/conf-file.html?highlight=trusted-users#conf-trusted-users)
in the `/etc/nix/nix.conf` of the server.
It makes sense that the build server requires this,
because building a Nix package is equivalent to having root access to the machine.

I would run:

```sh
echo "trusted-users = drew" | sudo tee -a /etc/nix/nix.conf
```

But I actually don't want this responsibility and it will probably not be too hard to just deal with the slower dev cycle for now.
I can always use `git commit --amend` to keep the history clean.

And what do you know, the build completes next time I build it from the server.
I think this workflow (build locally until no syntax errors, then push and build on server)
is fine in the end, since the NixOS module validation is so thorough.

I double check that the `/nix/var/nix/profiles/system/bin/switch-to-configuration` executable exists aaaand it does not.

Ah, the `--profile system` flag puts the build at `./system`.
If I want the profile at `/nix/var/nix/profiles/system`, then I should actually run:

```sh
nix build --profile /nix/var/nix/profiles/system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

This gets me thinking, though, do I even need a profile?
I could build it in the current directory and then run `./result/bin/switch-to-configuration` to install NixOS instead.

```sh
nix build github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

Except, can NixOS install without a system profile?
I'm curious, but reality kicks in and I realize I don't want to deal with the fallout of a botched installation.

I build the NixOS config and create the `/nix/var/nix/profiles/system` profile:

```sh
nix build --profile /nix/var/nix/profiles/system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

This runs into permissions issues, and then `sudo` doesn't have `nix` on the `PATH`,
so I end up using the absolute path to `nix`:

```sh
sudo /nix/var/nix/profiles/default/bin/nix build --profile /nix/var/nix/profiles/system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
```

## 6. Enabling lustrate mode

Just following the docs here.

```sh
sudo touch /etc/NIXOS
sudo touch /etc/NIXOS_LUSTRATE
```

## 7. Pre-install checklist

- [x] `/nix` is owned by root
    - `ls -ld /nix`
- [x] User has initial password
- [x] User has SSH key
- [x] Stop Docker services
- [x] Back up data
- [x] Export ZFS pool

## 8. Install

Move contents of `/boot` out of the way:

```sh
sudo mv -v /boot /boot.bak
```

Install NixOS:

```sh
sudo NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```
```
error:
       Failed assertions:
       - You must set the option ‘boot.loader.grub.devices’ or 'boot.loader.grub.mirroredBoots' to make the system bootable.
```

Huh. My understanding After some poking around and thinking is that because I set `NIXOS_INSTALL_BOOTLOADER=1`,
the `boot.loader.grub.devices` option is required so that NixOS knows which device to install the bootloader on.

https://github.com/NixOS/nixpkgs/issues/55332

I first get the path to my OS drive, by the drive ID.

```sh
export wwn=(lsblk /dev/sda --json --output wwn | jq -r '.blockdevices[0].wwn')
find /dev/disk/by-id | grep $wwn | head -n 1
```
```
/dev/disk/by-id/wwn-0x500a0751e1f50c03
```

I update my NixOS bootloader config to point at the device:

```diff
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x500a0751e1f50c03";
```

I push changes up, rebuild the profile, and try installing again.

```sh
sudo /nix/var/nix/profiles/default/bin/nix build --profile /nix/var/nix/profiles/system github:drewgingerich/homelab#nixosConfigurations.dusty-media-server.config.system.build.toplevel
sudo NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```
```
updating GRUB 2 menu...
installing the GRUB 2 boot loader on /dev/disk/by-id/wwn-0x500a0751e1f50c03...
Installing for i386-pc platform.
Installation finished. No error reported.
```

Success! Maybe. Time to reboot and see.

Okay, actual success!

Things to do after install:

- [x] Set a real password for my user
- [x] Start Tailscale
- [x] Update DNS records to point at new IP
- [x] Update SSH configs to point at new IP
- [x] Import ZFS pool
- [x] Start Docker services

