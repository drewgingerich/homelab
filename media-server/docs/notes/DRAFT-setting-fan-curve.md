# Setting fan curve

After moving to the new case, I noticed that the fans would spin up a lot every few seconds.

In the new case the fans are plugged into 4-pin mainboard fan headers,
while in old case the fans were plugged in an in-case fan controller with 3-pin connections.

My guess is that the fan curve set in the BIOS is spinning up the fans for even small CPU temperature increases.

The CPU fan may have been spinning up and down in the old case without me noticing because it's very quiet.

The [mainboard manual](https://www.supermicro.com/manuals/motherboard/C236/MNL-1785.pdf) states:

> \[F\an speed control is available for 4-pin fans only by Thermal Management via the IPMI 2.0 interface.

So looking in the [IPMI](https://www.supermicro.com/manuals/other/IPMI_Users_Guide.pdf) web UI seems like a good bet.

I don't normally have the BMC ethernet port connected, so I do that.

I look at my router's device table to find the IP address and navigate there in my browser.

The username is `ADMIN` and the password is also `ADMIN`, which are the defaults.

The first thing I do is update the password.
And then I try re-logging in and I can't!
I should have made a second user with a simple password before checking.

SuperMicro provides the [`ipmicfg` tool](https://www.supermicro.com/Bios/sw_download/760/IPMICFG_UserGuide.pdf) for cases like this.
It is used as bootable EFI software to configure IPMI stuff, including changing user passwords.

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

My plan to set `ipmicfg` seems like it's out the window.
I'll need to get some display output over HDMI.

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
The mainboard has a VGA port, so I can get an host VGA to display HDMI adapter.




---

I download `ipmicfg` from [the download page](https://www.supermicro.com/en/support/resources/downloadcenter/smsdownload?category=IPMI)

`systemctl reboot --firmware-setup`

https://www.servethehome.com/reset-supermicro-ipmi-password-default-lost-login/
https://serverhub.com/kb/how-to-reset-ipmi-bmc-to-factory-default-using-ipmicfg/

https://stackoverflow.com/questions/32223339/how-does-uefi-work
https://uefi.org/specifications
https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface
https://medium.com/@kartikaybhardwaj77/a-deep-dive-into-the-efi-shell-unlocking-the-power-of-pre-boot-environment-1ce5e4a4768c
https://safeboot.dev/
