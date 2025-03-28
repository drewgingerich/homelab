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
This generated a log file at `~/steam-620980.log`.
The logs were long and I only found the expected errors
about failing to load an OpenXR runtime, with no additional information.

I check the WiVRn service status with `systemctl --user status wivrn`.
It is active and running.

I check the logs with `journalctl --user --follow --unit wivrn.service`
and don't see anything obvious.

While looking at this, I noticed that the WiVRn service had crashed and couldn't restart
because it had started on my other user instead and was hogging the port.

In [250328A-using-a-systemd-unit-file-from-a-nixos-package.md](/game-server/docs/notes/250328A-using-a-systemd-unit-file-from-a-nixos-package.md)
I take a little detour and set up a systemd unit for WiVRn with Home Manager.

https://www.reddit.com/r/linux_gaming/comments/ve23bv/psa_you_can_run_proton_manually/

---

I am trying to get [WlxOverlay-S](https://github.com/galister/wlx-overlay-s) to work.
I am seeing the watch and keyboard UI, but not the desktop.

The WlxOverlay-S [known issues docs](https://github.com/galister/wlx-overlay-s?tab=readme-ov-file#known-issues)
brings up a phantom monitor as a possible issue.

I list the monitors:

```sh
$ xrandr -q
Screen 0: minimum 16 x 16, current 1920 x 1080, maximum 32767 x 32767
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 1600mm x 900mm
```

The `HDMI-1` monitor is expected, but `Screen 0` is not.

After poking around the internet a bit, I learned that `Screen 0` is actually expected.
A screen is an abstraction over one or more monitors,
and the `Screen 0` resolution matching the `HDMI-1` resolution suggests things are working fine.

https://askubuntu.com/questions/981609/select-screen-0-with-xrandr

## Other reading

https://wiki.archlinux.org/title/Xrandr#Disabling_phantom_monitor
https://github.com/NixOS/nixpkgs/issues/321603#issuecomment-2188410213
https://www.reddit.com/r/linux4noobs/comments/dx5dze/xrandr_shows_two_displays_when_i_only_use_one/

