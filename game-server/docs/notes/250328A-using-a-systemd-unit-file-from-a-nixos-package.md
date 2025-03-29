# Using a systemd unit file from a NixOS package

The [WiVRn NixOS module](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/video/wivrn.nix)
provides a systemd unit to start the WiVRn server and an `autoStart` option to enable the unit.

```nix
{ ... }:
{
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
  };
}
```

The unit is run using the NixOS [`systemd.user.units` option](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/system/boot/systemd/user.nix),
which means it is run as a user unit for every user.
This becomes problematic when multiple users log in because
there is a port conflict and which process gets it is non-deterministic.

Instead of using the `autoStart` option, I want to use Home Manager to enable the unit for only one user.
My first attempt is to set the Home Manager [`systemd.user.services.wivrn`](https://nix-community.github.io/home-manager/options.xhtml#opt-systemd.user.services)
option to the value of the NixOS `systemd.user.service.wivrn` option.

```nix
{ config, ... }:
let
  wivrn_service = config.systemd.user.services.wivrn;
in
{
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
  };
  home-manager.users.dreamy = {
    systemd.user.services.wivrn = wivrn_service // {
      wantedBy = ["default.target"];
    };
  };
}
```

This did not work because the NixOS and Home Manager `systemd.user.services` options have different specifications.

When poking around the WiVRn package in the Nix store, I noticed that the systemd unit file is there.
Instead of trying to reuse the unit config within Nix, I realized I could copy the unit file into
`~/.config/systemd/user/graphical-session.target.wants`.
This is a special folder that will cause systemd to automatically load and start the unit.

```nix
{ pkgs, ... }:
{
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
  };
  home-manager.users.dreamy = {
    config = {
      xdg.configFile = {
        "systemd/user/graphical-session.target.wants/wivrn.service" = {
          source = "${pkgs.wivrn}/share/systemd/user/wivrn.service";
        };
      };
    };
  };
}
```

It works! The unit runs for this user, and not for any other user.
Interestingly the unit is still enabled for all users,
this approach just makes it active for only the specified user.

```nix
$ systemctl --user status wivrn
○ wivrn.service - WiVRn XR runtime service
     Loaded: loaded (/etc/systemd/user/wivrn.service; enabled; preset: ignored)
     Active: inactive (dead)
$ sudo systemctl --machine=dreamy@ --user status wivrn
● wivrn.service - WiVRn XR runtime service
     Loaded: loaded (/etc/systemd/user/wivrn.service; enabled; preset: ignored)
     Active: active (running) since Fri 2025-03-28 22:15:30 PDT; 2min 59s ago
 Invocation: 55a06754eaad47619e83b817eb7bbd94
   Main PID: 1744
      Tasks: 4 (limit: 37325)
     Memory: 30.1M (peak: 30.7M)
        CPU: 42ms
     CGroup: /user.slice/user-1002.slice/user@1002.service/app.slice/wivrn.service
             └─1744 /nix/store/wcyhba3n2lp612jwaica0qlwvg8nyvxi-wivrn-0.23.2/bin/wivrn-server --systemd
```
