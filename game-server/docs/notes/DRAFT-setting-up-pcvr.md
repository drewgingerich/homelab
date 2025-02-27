# Setting up PCVR

I have a Meta Quest 3 headset.
I want to be able to stream games from my server to the headset (known as PCVR)
because I'd much rather use Steam over the Meta store.

To stream games to the headset, I need to connect the headset to the server.

While I could use a cable, I prefer a cable-free experience and
It's possible to stream over Wi-Fi instead.

Meta has a proprietary offering for wireless streaming called Air Link,
but can only connect to Windows PCs[^1].
[ALVR] is an open-source alternative to Air Link,
and can establish a connection between a Quest and Linux PC.

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


One option is to use a hard-wired connection with a cable.
I like the cable-free experience, so 
Since I use the headset in the living room and my server is in the basement,
I'd need to run the cable down to the server.
I want to minimize the number 



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
