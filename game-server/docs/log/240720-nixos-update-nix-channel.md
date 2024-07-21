I tried to install https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/sunshine.nix,
but got error that `services.sunshine` didn't exist.

I guessed the issue was that NixOS was not pulling from the latest nixpkgs.
Looking around a bit, I found out that the version of nixpkgs used can be selected using [Nix channels](https://nixos.wiki/wiki/Nix_channels).

To list the channels my system had configured:

```
$ sudo nix-channel --list
nixos https://nixos.org/channels/nixos-23.11
```

Based on the wiki, to most recent stable is at version 24.05
My system is a major version behind.

To add the current version:

```
$ sudo nix-channel --add stable https://nixos.org/channels/nixos-24.05
$ sudo nix-channel --remove nixos
```

I named it `stable` thinking this would help me understand what channel this is in the future.
Running `sudo nixos-rebuild switch` I ran into errors about the `nixos` channel missing.
I realized that NixOS specifically uses the channel named `nixos`.

To rename the channel I added it again with the corrent name and removed `stable`:

```
$ sudo nix-channel --add nixos https://nixos.org/channels/nixos-24.05
$ sudo nix-channel --remove stable
```

This allowed me to get the latest packages from nixpkgs.

I see that a new stable channel is released every six months.
If I want to get updates earlier, I can use the unstable channel.
Once I get more familiar with NixOS's rollback capabilities,
I may opt into using the unstable channel.
