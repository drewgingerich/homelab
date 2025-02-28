# Setting up wireless PCVR

I have a Meta Quest 3 headset.
I want to be able to stream games from my server to the headset (known as PCVR)
because I'd rather use Steam over the Meta store.

To stream games to the headset, I need to connect the headset to the server.
While I could use a cable, I prefer a cable-free experience and
It's possible to stream over Wi-Fi instead.

Meta has a proprietary offering for wireless streaming called Air Link,
but it can only connect to Windows PCs[^1].

There are several open-source alternatives that can connect to a Linux PC:

1. [ALVR](https://github.com/alvr-org/ALVR), based on [OpenVR](https://en.wikipedia.org/wiki/OpenVR)
2. [WiVRn](https://github.com/WiVRn/WiVRn), based on [OpenXR](https://en.wikipedia.org/wiki/OpenXR)

OpenVR and OpenXR are standards for VR runtimes.
A VR runtime provides abstractions over VR hardware that makes it easier to develop VR programs.

https://github.com/mbucchia/VirtualDesktop-OpenXR/wiki/Oculus-%22Runtimes%22#what-is-a-runtime

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


ALVR requires the client to be installed on the headset and
the server to be installed on the PC.
I installed the client on the headset through the Meta store, no fuss.
I installed the server using the NixOS module:

```nix
  # Other NixOS configuration...
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
```

To actually play steam games, 

OpenVR is an SDK that provides abstraction over headset hardware.
It allows game developers to avoid implementing logic for every piece of hardware separately.


The de facto standard for PCVR is [SteamVR](https://store.steampowered.com/steamvr).
It appears to have Linux support at this time, with some constraints[^1].
Since I'm using Gnome X11 at this time, it looks like my system should meet these constraints.

I installed SteamVR on my game server through the Steam store.

SteamVR required super user access to set up after starting,
which I wasn't providing to the `steam` user. 

```sh
$ sudo usermod -aG wheel steam
```

[^1]: https://www.meta.com/help/quest/articles/headsets-and-accessories/oculus-link/connect-with-air-link/
[^2]: https://help.steampowered.com/en/faqs/view/18A4-1E10-8A94-3DDA

https://lvra.gitlab.io/
https://medium.com/@bvjebin/yours-insanely-offline-first-3b946e526cc1
https://www.youtube.com/watch?v=o8ho7VG13Ck
https://www.youtube.com/watch?v=_5k9htTdpuI
https://www.reddit.com/r/oculus/comments/4j9qi8/psa_guide_to_the_differences_between_oculus_home/
https://developers.meta.com/horizon/blog/asynchronous-timewarp-examined/
