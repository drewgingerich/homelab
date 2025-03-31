# Setting up wireless PCVR

I have a Meta Quest 3 headset.
I want to be able to stream games from my server to the headset (known as PCVR)
because I'd rather use Steam over the Meta store.

To stream games to the headset, I need to connect the headset to the server.
While I could use a cable, I prefer a cable-free experience and
It's possible to stream over Wi-Fi instead.

Meta has a proprietary offering for wireless streaming called Air Link,
but it can only connect to Windows PCs.

https://www.meta.com/help/quest/articles/headsets-and-accessories/oculus-link/connect-with-air-link/

I found two open-source alternatives that can connect to a Linux PC wirelessly:

1. [ALVR](https://github.com/alvr-org/ALVR), based on [OpenVR](https://en.wikipedia.org/wiki/OpenVR)
2. [WiVRn](https://github.com/WiVRn/WiVRn), based on [OpenXR](https://en.wikipedia.org/wiki/OpenXR)

https://lvra.gitlab.io

OpenVR and OpenXR are standards for VR runtimes.
A VR runtime provides abstractions over VR hardware that makes it easier to develop VR programs.

https://github.com/mbucchia/VirtualDesktop-OpenXR/wiki/Oculus-%22Runtimes%22#what-is-a-runtime
https://developers.meta.com/horizon/blog/asynchronous-timewarp-examined/

While OpenVR is technically open-source, it is defined by Valve and the main implementation is the proprietary SteamVR.
OpenXR is open-source and defined by the Khronos Group, a non-profit.

I'd rather use OpenXR, so I will try WiVRn.
There is a NixOS module for it:

```nix
services.wivrn = {
  enable = true;
  openFirewall = true;
  defaultRuntime = true;
  autoStart = true;
};
```

After running a Nix rebuild and rebooting the computer,
I check to see if it's running:

```sh
$ sudo systemctl status wivrn
Unit wivrn.service could not be found.
```

I decided to check if it's running as a user service:

```sh
$ systemctl --user status wivrn
○ wivrn.service - WiVRn XR runtime service
     Loaded: loaded (/etc/systemd/user/wivrn.service; enabled; preset: ignored)
     Active: inactive (dead) since Mon 2025-03-10 20:36:38 PDT; 20min ago
   Duration: 62ms
 Invocation: d4afe760ca804df0a7d8c61ec8cd80a9
    Process: 5266 ExecStart=/nix/store/wcyhba3n2lp612jwaica0qlwvg8nyvxi-wivrn-0.23.2/bin/wivrn-server --systemd (code=exited, status=0/SUCCESS)
   Main PID: 5266 (code=exited, status=0/SUCCESS)
   Mem peak: 8.9M
        CPU: 32ms

Mar 10 20:36:38 unremarkable-game-server systemd[5246]: Started WiVRn XR runtime service.
Mar 10 20:36:38 unremarkable-game-server wivrn-server[5266]: WiVRn v0.23.2 starting
Mar 10 20:36:38 unremarkable-game-server wivrn-server[5266]: For Steam games, set command to PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn>
Mar 10 20:36:38 unremarkable-game-server wivrn-server[5266]: Address already in use
```

So yes, but it exited.
I check if it's running under the auto-login user `dreamy`:

```sh
$ sudo systemctl --user --machine=dreamy@ status wivrn
● wivrn.service - WiVRn XR runtime service
     Loaded: loaded (/etc/systemd/user/wivrn.service; enabled; preset: ignored)
     Active: active (running) since Sat 2025-03-08 22:34:15 PST; 1 day 21h ago
 Invocation: fd31cac43c754bb0ba6f7eb585137a29
   Main PID: 1543
      Tasks: 4 (limit: 37325)
     Memory: 31.9M (peak: 32.7M)
        CPU: 42ms
     CGroup: /user.slice/user-1002.slice/user@1002.service/app.slice/wivrn.service
             └─1543 /nix/store/wcyhba3n2lp612jwaica0qlwvg8nyvxi-wivrn-0.23.2/bin/wivrn-server --systemd
```

That is the behavior I want, but I'd like to better understand why.
It appears to be because the WiVRn module configures the service using the `systemd.user` option,
which runs it as a user service for all users.
The auto-login user generally runs it first and claims the port,
but there is the potential for conflict.

https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/video/wivrn.nix#L180
https://discourse.nixos.org/t/what-is-the-difference-between-systemd-services-and-systemd-user-services/25222/6

If I need to make sure it only runs for a single user in the future, I think I can set `autoStart` to `false`
and create a user service for the `dreamy` user using Home Manager.

In a graphical session for `dreamy`, I open the WiVRn server application.
I select the wizard tab and follow the instructions,
including installing WiVRn on my Quest 3 from the Meta store.
I successfully establish a connection between my headset and PC.

The next thing to do is try to actually run something.

I first check the headset and see that it's still connected to the PC.
I open Beat Saber through Steam on the PC, running using Proton's hotfix channel.
Beat Saber opens on the TV and pops up a warning saying `OpenXR Runtime was not found.`

In Steam, I set Beat Saber's launch options to `PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%`.

https://wiki.nixos.org/wiki/VR#WiVRn

I still got the same warning.
To get some more information I added `PROTON_LOG=1` to the launch options as well.

https://github.com/ValveSoftware/Proton/blob/proton_9.0/README.md#runtime-config-options

This generated a log file at `~/steam-620980.log`.
The logs were long and I only found the expected errors
about failing to load an OpenXR runtime, with no additional information.

I check the WiVRn service status with `systemctl --user status wivrn`.
It is active and running.

I check the logs with `journalctl --user --follow --unit wivrn.service`
and don't see anything obvious.

So, not much to go on.

While looking at this, I noticed that the WiVRn service had crashed and couldn't restart
because it had started on my other user instead and was hogging the port.
In [250328A-using-a-systemd-unit-file-from-a-nixos-package.md](/game-server/docs/notes/250328A-using-a-systemd-unit-file-from-a-nixos-package.md)
I take a little detour and set up a systemd unit for WiVRn with Home Manager.

On the NixOS wiki VR page I do see that [OpenComposite](https://gitlab.com/znixian/OpenOVR) is required
when running games in Proton.

https://wiki.nixos.org/wiki/VR#OpenComposite

As described in the OpenXR specs, the OpenXR runtime is discovered by looking for a JSON file in a few well-known places.
The WiVRn NixOS module places a file at one of these, `/etc/xdg/openxr/1/active_runtime.json`,
so WiVRn should be discovered as an OpenXR runtime.
Notably this appears to be the lowest priority location,
so if I run into trouble it could be because something else has put a file at a higher priority location.

https://registry.khronos.org/OpenXR/specs/1.0/loader.html#runtime-discovery

For native OpenXR games and applications, this should be enough.

Not all games support OpenXR, though, and this is where OpenComposite comes in:
OpenComposite is an OpenVR runtime that simply translates and forwards calls to an OpenXR runtime.
Games that need an OpenVR runtime think they are using an OpenVR runtime,
even if the real work is done by an OpenXR runtime.

The internet says that games run with Proton require a working OpenVR runtime, even when using OpenXR,
though I have trouble finding out why this actually is.
This means that OpenComposite is necessary for all VR games run in Proton.

OpenVR has a runtime discover process similar to OpenXR:
it looks for the file `$XDG_CONFIG_DIR/openvr/openvrpaths.vrpath`,
a JSON file containing the path to the OpenVR runtime library, log output path, and other values.

To use OpenComposite, this file must be updated to point at the OpenComposite DLL.

Altogether in the user's Home Manager config it looks like this:

```nix
home.packages = [ pkgs.opencomposite ];
xdg.configFile."openvr/openvrpaths.vrpath".text = ''
  {
    "config": [ "${config.xdg.dataHome}/Steam/config" ],
    "external_drivers": null,
    "jsonid": "vrpathreg",
    "log": [ "${config.xdg.dataHome}/Steam/logs" ],
    "runtime": [ "${pkgs.opencomposite}/lib/opencomposite" ],
    "version": 1
  }
'';
```

https://forum.dcs.world/topic/314178-opencomposite-and-differents-dlls-why/

Unfortunately Beat Saber still complains about not finding an OpenXR runtime.

I try running a different game, Republique VR, with Proton logging enabled.
I come across these errors:

```
984.829:0020:0128:err:steam:initialize_vr_data Could not load libopenvr_api.so.
```
```
warn:  OpenXR: Unable to get required Vulkan instance extensions size
```
```
warn:  OpenXR: Unable to get required Vulkan Device extensions size
```

Looking around the internet, it seems like non of these are it.

Next I tried adding `WINEDEBUG=all` to the launch options to get more logs, but this caused games to crash.
There was a clear error in the Proton log file, but I don't remember what it was.

https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Developer's-Guide/Debugging-Wine

I came across the `nixpkgs-xr` project and tried adding that to my NixOS config.

```nix
{
  description = "System configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs = {
    nix-darwin,
    home-manager,
    nixpkgs,
    nixpkgs-xr,
    ...
  }: {
    nixosConfigurations.unremarkable-game-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixpkgs-xr.nixosModules.nixpkgs-xr
        home-manager.nixosModules.home-manager
        ./game-server/nix/configuration.nix
      ];
    };
  };
}
```

https://github.com/nix-community/nixpkgs-xr

This also didn't work.

Reaching the end of the road, I upgraded my `flake.lock` file.

```sh
$ nix flake update
```

And what do you know, things started working.
I guess a reminder to update things first,
because maybe the latest versions already work.

After things started working I tried removing the `nixpkgs-xr` module, and things continued to work.

