# IPMI password troubles

I tried changing the password of the IPMI admin user,
and now I can't log in.

I should have made a second user with a simple password before checking.

Looking around, the problem appears to be that the IPMI spec (which SuperMicro follows) only
allows passwords of 8-20 characters, but the IPMI web UI didn't stop me from setting a 25 character password.
I try entering the first 20 characters of the password but I still can't get in.

https://www.reddit.com/r/sysadmin/comments/1e4v3w6/supermicro_ipmi_password_length_820_characters_why/
https://www.reddit.com/r/homelab/comments/7vvuvp/please_help_an_idiot_regain_access_to_ipmi/

SuperMicro provides the [`ipmicfg` tool](https://www.supermicro.com/Bios/sw_download/760/IPMICFG_UserGuide.pdf) for cases like this.
It is used as bootable EFI software to configure IPMI stuff, including changing user passwords.

https://www.servethehome.com/reset-supermicro-ipmi-password-default-lost-login/
https://serverhub.com/kb/how-to-reset-ipmi-bmc-to-factory-default-using-ipmicfg/
https://stackoverflow.com/questions/32223339/how-does-uefi-work
https://uefi.org/specifications
https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface
https://medium.com/@kartikaybhardwaj77/a-deep-dive-into-the-efi-shell-unlocking-the-power-of-pre-boot-environment-1ce5e4a4768c
https://safeboot.dev/

---

I take a quick detour to connect a keyboard, display, and mouse to the server.
I was trying to avoid this by using the IPMI web interface, but that's a no-go for now.

With everything connected I don't get any HDMI output.
I believe this is because I did a headless installation of Ubuntu,
so it doesn't have the software necessary for displaying over HDMI.

Without IPMI or HDMI I don't have any way to look in the BIOS or bootloader,
to e.g. select the boot device.
This is something of a problem, but I may be able to set `ipmicfg` as the first UEFI boot target and
deal with that lack of visibility that way.

For that matter, I don't even know if my system is using UEFI.

```sh
$ ls /sys/firmware/efi
ls: cannot access '/sys/firmware/efi': No such file or directory
```

The lack of the `/sys/firmware/efi` file indicates my system is booting using legacy BIOS.

https://askubuntu.com/questions/162564/how-can-i-tell-if-my-system-was-booted-as-efi-uefi-or-bios

My plan to set `ipmicfg` seems like it's out the window,
and that I'll need to get some display output over HDMI.

Thinking about it more, I don't think a headless installation of Ubuntu should
prevent the BIOS from showing up on an external monitor.
The problem could lie elsewhere.

I connect the display to the GPU HDMI port,
since the mainboard doesn't have integrated graphics or an HDMI port.

The GPU appears to be running fine:

```sh
$ nvidia-smi
Wed Feb 12 17:07:43 2025
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.256.02   Driver Version: 470.256.02   CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
|  0%   28C    P0    23W / 120W |      0MiB /  6078MiB |      2%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

It might be easiest to take the GPU out of the picture and
connect the display to the mainboard directly.
The mainboard has a VGA port, so I can get a host VGA to display HDMI adapter.

---

While waiting for the VGA to HDMI adapter, I take another look around at how I can might reset the IPMI admin password.


It seems like I might be able to do this with [OpenIPMI](https://openipmi.sourceforge.io/), and IPMI driver for Linux,
and [ipmitool](https://github.com/ipmitool/ipmitool), a CLI for managing IPMI using the OpenIPMI driver.


```sh
$ sudo apt update
$ sudo apt install openipmi ipmitool
$ ipmitool user list
Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0: No such file or directory
```

This failure is not surprising because I believe I have to add some kernel modules to get the OpenIPMI driver to work.

---

After reading more Reddit posts, I decided to try the first 19 characters of the password I set.
It works!

While I'm a little sad not have a clear reason to learn more about IPMI and UEFI,
I'm also quite happy to move on.

```sh
$ sudo apt remove openipmi ipmitool
$ sudo apt autoremove
```
