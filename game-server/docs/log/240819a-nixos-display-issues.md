I thought the issue might be due to using Wayland somehow,
so I tried forcing use of X11 instead.

```nix
services.xserver.displayManager.gdm.wayland = false;
```

After a reboot, `nvidia-smi` showed no running processes.

```sh
$ nvidia-smi
Sat Aug 17 09:56:06 2024
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.78                 Driver Version: 550.78         CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3080        Off |   00000000:06:10.0 Off |                  N/A |
|  0%   31C    P8             12W /  320W |       2MiB /  10240MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

Not great. Looking at `journalctl` didn't show much.

```sh
$ sudo journalctl -r | less
Aug 17 09:55:37 nixos sunshine[1647]: [2024:08:17:09:55:37]: Info: Terminate handler called
```

Looking at systemd unit status only shows that it's dead.

```sh
$ sudo systemctl --user --machine=steam@ status sunshine
○ sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/etc/systemd/user/sunshine.service; enabled; preset: enabled)
     Active: inactive (dead)
```

I decided to go back to Wayland and troubleshoot there.

After switching back, things appeared to be working.
It seems like an intermittent problem that I'll have to keep an eye on.

Looking at the display settings in the GUI,
I did notice that there was a second monitor there titled _Red Hat, Inc. 15"_.

After thinking about where this might be coming from,
I realized that I hadn't removed the _Default_ display hardware in the Proxmox VM settings.
This second display was a virtual one.
Since it could be conflicting with the HDMI dummy plug, I removed it in the Proxmox GUI.

This resulted in getting a text mode login at boot again.

I tried out `sddm` instead of `gdm` as a long shot,
in case the display manager had any influence.

```nix
services.xserver.displayManager.sddm.enable = true;
```

It still didn't provide a GUI login screen, though the text-mode login looked a bit different.
I switched back to `gdm`.

At this point I didn't have a great idea of where to go.
It seemed like the dummy HDMI plug wasn't being detected, configured, or used properly.
I'm not familiar with how displays and display managers work in Linux.

The next steps I could think of were:

1. Plug in a real display to see if things are working.
2. Try to see if the HDMI display is being detected and configured properly.
3. Look at `gdm` logs. There might be an obvious error.

Plugging in a real display showed the homepage,
meaning graphics was set up and automatic login was working.

Connecting via Moonlight showed a text mode tty.
The problem appeared to be with Moonlight or Sunshine, rather than graphics drivers or display.

I had trouble getting Sunshine logs by systemd unit.

```sh
$ journalctl -u sunshine.service
-- No entries --
```

I was able to get Sunshine logs by PID.

```sh
$ sudo ps -ax | grep sunshine
   1697 ?        Ssl    3:49 /run/wrappers/bin/sunshine
   2185 pts/0    S+     0:00 grep sunshine
$ journalctl _PID=1697
```

I saw a ton of one error in particular.

> Warning: Couldn't get drm fb for plane [0]: No such file or directory

I believed `drm fb` stands for _Direct Rendering Manager framebuffer_.[^1]
Sunshine was trying to capture a frame from the framebuffer, but it didn't exist.

One thing I noticed in the GUI displays menu is that there was still a second monitor: _Unknown 15.6"_.
I didn't know if this was related to my problem, but it seemed fishy.

Looking around, I found a GitHub issue[^2] that talked about this.
The fix there was some NixOS config.

```nix
boot.kernelParams. = [ "nvidia-drm.fbdev=1" ];
```

After a reboot, this did remove the _Unknown 15.6"_ display.
Best of all, Sunshine and Moonlight were working again!
Sunshine must have been trying to capture the output of that weird display.

## References

[^1]: https://en.wikipedia.org/wiki/Direct_Rendering_Manager
[^2]: https://github.com/NixOS/nixpkgs/issues/302059

https://www.reddit.com/r/swaywm/comments/ykk5ks/sunshine_moonlight_works_on_sway_for_remote/
