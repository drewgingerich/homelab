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

There are several open-source alternatives that can connect to a Linux PC:

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

https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/video/wivrn.nix#L180
https://discourse.nixos.org/t/what-is-the-difference-between-systemd-services-and-systemd-user-services/25222/6

If I need to make sure it only runs for a single user in the future, I think I can set `autoStart` to `false`
and create a user service for the `dreamy` user using Home Manager.

I the graphical session for `dreamy` I run `wivrn-dashboard` to open up a connection wizard.
I follow the instructions, including installing WiVRn on my Quest 3 from the Meta store,
and successfully establish a connection.

