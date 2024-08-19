I noticed that `nvidia-smi` shows `Xwayland` as a process. 

```sh
$ nvidia-smi
Fri Aug 16 22:52:00 2024
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.78                 Driver Version: 550.78         CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3080        Off |   00000000:06:10.0 Off |                  N/A |
|  0%   31C    P8              9W /  320W |     223MiB /  10240MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A      1234      G   ...f9-gnome-shell-46.2/bin/gnome-shell        177MiB |
|    0   N/A  N/A      1646      G   ...x2klrd-xwayland-24.1.0/bin/Xwayland          5MiB |
|    0   N/A  N/A      1679      G   /run/wrappers/bin/sunshine                      5MiB |
|    0   N/A  N/A      7163      G   ...local/share/Steam/ubuntu12_32/steam          3MiB |
|    0   N/A  N/A      7835      G   ./steamwebhelper                                7MiB |
+-----------------------------------------------------------------------------------------+
```

This was puzzling since I though I was using Xorg.
I thought perhaps this had something to do with the broken automatic login.

I started by verifying that the GUI session was using Wayland.

```sh
$ loginctl
SESSION  UID USER  SEAT  TTY   STATE  IDLE SINCE
      1 1002 steam seat0 tty1  active yes  4h 23min ago
      5 1000 drew  -     pts/0 active no   -
$ loginctl show-session 1 -p Type
Type=wayland
```

To see if this had anything to do with installing the Nvidia drivers and using GPU passthrough,
I commented out the driver config, stopped passing the GPU, and rebooted the VM.

```sh
$ loginctl
SESSION  UID USER  SEAT  TTY   STATE  IDLE SINCE
      1 1002 steam seat0 tty1  active no   -
      3 1000 drew  -     pts/0 active no   -
$ loginctl show-session 1 -p Type
Type=wayland
```

So that doesn't seem to have anything to do with.
There's a strong possibility I was running Wayland this whole time and didn't realize.
Or maybe it switched to Wayland when I updated the NixOS channel to 24.05.

I decided to re-configure GPU passthrough and move on.

https://github.com/NixOS/nixpkgs/issues/103746
