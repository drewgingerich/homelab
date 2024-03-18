## Installing Flatpak

Flatpak is a simple way to install applications.
I like that the installed applications are isolated and easy to uninstall.
This makes experimentation easier and more relaxed.

```
sudo apt update
sudo apt install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Installing Sunshine 

I installed Sunshine using flatpak:
```
sudo flatpak install flathub dev.lizardbyte.app.Sunshine
```

I ran Sunshine with `flatpak run dev.lizardbyte.app.Sunshine`,
but was presented with a bunch of errors:

```
[2024:03:09:17:56:00]: Info: Sunshine version: 0.22.0.c63637f.dirty
Cannot load libcuda.so.1
[2024:03:09:17:56:00]: Error: Couldn't load cuda: -1
[2024:03:09:17:56:00]: Error: Failed to gain CAP_SYS_ADMIN
[2024:03:09:17:56:00]: Error: Couldn't open: /dev/dri/card0: Permission denied
[2024:03:09:17:56:00]: Error: Environment variable WAYLAND_DISPLAY has not been defined
[2024:03:09:17:56:00]: Error: Unable to initialize capture method
[2024:03:09:17:56:00]: Error: Platform failed to initialize
[2024:03:09:17:56:00]: Error: Could not create Sunshine Mouse (Relative): Permission denied
[2024:03:09:17:56:00]: Error: Could not create Sunshine Mouse (Absolute): Permission denied
[2024:03:09:17:56:00]: Error: Could not create Sunshine Keyboard: Permission denied
[2024:03:09:17:56:00]: Error: Falling back to XTest for virtual input! Are you a member of the 'input' group?
[2024:03:09:17:56:00]: Info: // Testing for available encoders, this may generate errors. You can safely ignore those errors. //
[2024:03:09:17:56:00]: Info: Trying encoder [nvenc]
[2024:03:09:17:56:00]: Warning: Failed to create system tray
[2024:03:09:17:56:01]: Info: Encoder [nvenc] failed
[2024:03:09:17:56:01]: Info: Trying encoder [vaapi]
[2024:03:09:17:56:01]: Info: Encoder [vaapi] failed
[2024:03:09:17:56:01]: Info: Trying encoder [software]
[2024:03:09:17:56:02]: Info: Encoder [software] failed
[2024:03:09:17:56:02]: Fatal: Unable to find display or encoder during startup.
[2024:03:09:17:56:02]: Fatal: Please check that a display is connected and powered on.
[2024:03:09:17:56:02]: Error: Video failed to find working encoder
[2024:03:09:17:56:02]: Info: Open the Web UI to set your new username and password and getting started
[2024:03:09:17:56:02]: Info: File /home/drew/.var/app/dev.lizardbyte.app.Sunshine/config/sunshine/sunshine_state.json doesn't exist
[2024:03:09:17:56:02]: Info: Adding avahi service Sunshine
[2024:03:09:17:56:02]: Info: Configuration UI available at [https://localhost:47990]
[2024:03:09:17:56:02]: Info: Avahi service Sunshine successfully established.
```
 
## Installing NVIDIA drivers

I was using the default NVIDIA drivers, which I assumed didn't support CUDA.
I knew I should probabaly install the proprietary NVIDIA drivers anyways,
for best performance and featureset.

Ubuntu has a command for installing drivers: `ubuntu-drivers`.
It can install specific drivers,
but I decided to trust its automatic detection and ran `sudo ubuntu-drivers install`.

After the installation completed successfully,
I rebooted the system so the GPU would be bind to the new driver.

After the reboot I ran `lspci -nnk` to see which driver was being used, which gave:

```
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080] [10de:2206] (rev a1)
        Subsystem: ZOTAC International (MCO) Ltd. GA102 [GeForce RTX 3080] [19da:1612]
        Kernel driver in use: nvidia
        Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia  
```

This showed me the new driver was being used.

As another check, I ran `nvidia-smi`, which showed:

```
Sat Mar  9 18:08:24 2024
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.161.07             Driver Version: 535.161.07   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3080        Off | 00000000:01:00.0 Off |                  N/A |
|  0%   26C    P8               3W / 320W |     73MiB / 10240MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
```

This also indicated the proprietary drivers were working.
The driver version (535) and CUDA version (12.2) were both higher than the minimum versions listed in the Sunshine docs.

Since the errors were complaining about not being able to load CUDA,
I also installed CUDA with `sudo apt install nvidia-cuda-toolkit`.

## Running Sunshine

Trying to start Sunshine resulted in the same errors as before. 

I remembered reading that using the GPU required a display,
but I was trying to run it over an SSH terminal.
I connected a display, mouse, and keyboard and ran Sunshine again.

```
$ flatpak run dev.lizardbyte.app.Sunshine 
[2024:03:13:18:48:46]: Info: Sunshine version: 0.22.0.c63637f.dirty
Cannot load libcuda.so.1
[2024:03:13:18:48:46]: Error: Couldn't load cuda: -1
[2024:03:13:18:48:46]: Error: Failed to gain CAP_SYS_ADMIN
Gtk-Message: 18:48:46.590: Failed to load module "canberra-gtk-module"
Gtk-Message: 18:48:46.592: Failed to load module "canberra-gtk-module"
[2024:03:13:18:48:46]: Info: System tray created
[2024:03:13:18:48:46]: Error: Environment variable WAYLAND_DISPLAY has not been defined
[2024:03:13:18:48:46]: Info: Detecting monitors
[2024:03:13:18:48:46]: Info: Detected monitor 0: HDMI-0, connected: true
[2024:03:13:18:48:46]: Info: Detected monitor 1: DP-0, connected: false
[2024:03:13:18:48:46]: Info: Detected monitor 2: DP-1, connected: false
[2024:03:13:18:48:46]: Info: Detected monitor 3: DP-2, connected: false
[2024:03:13:18:48:46]: Info: Detected monitor 4: DP-3, connected: false
[2024:03:13:18:48:46]: Info: Detected monitor 5: DP-4, connected: false
[2024:03:13:18:48:46]: Info: Detected monitor 6: DP-5, connected: false
[2024:03:13:18:48:46]: Info: // Testing for available encoders, this may generate errors. You can safely ignore those errors. //
[2024:03:13:18:48:46]: Info: Trying encoder [nvenc]
[2024:03:13:18:48:46]: Info: Screencasting with X11
Cannot load libcuda.so.1
[2024:03:13:18:48:46]: Error: Couldn't load cuda: -1
Cannot load libcuda.so.1
[2024:03:13:18:48:46]: Error: Couldn't load cuda: -1
[2024:03:13:18:48:46]: Info: Encoder [nvenc] failed
[2024:03:13:18:48:46]: Info: Trying encoder [vaapi]
[2024:03:13:18:48:46]: Info: Screencasting with X11
[2024:03:13:18:48:46]: Info: SDR color coding [Rec. 601]
[2024:03:13:18:48:46]: Info: Color depth: 8-bit
[2024:03:13:18:48:46]: Info: Color range: [JPEG]
libva info: VA-API version 1.18.0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/intel-vaapi-driver/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/GL/lib/dri/nvidia_drv_video.so
libva info: va_openDriver() returns -1
[2024:03:13:18:48:46]: Error: Couldn't initialize va display: unknown libva error
[2024:03:13:18:48:46]: Info: SDR color coding [Rec. 601]
[2024:03:13:18:48:46]: Info: Color depth: 8-bit
[2024:03:13:18:48:46]: Info: Color range: [JPEG]
libva info: VA-API version 1.18.0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/intel-vaapi-driver/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/GL/lib/dri/nvidia_drv_video.so
libva info: va_openDriver() returns -1
[2024:03:13:18:48:46]: Error: Couldn't initialize va display: unknown libva error
[2024:03:13:18:48:46]: Info: SDR color coding [Rec. 601]
[2024:03:13:18:48:46]: Info: Color depth: 8-bit
[2024:03:13:18:48:46]: Info: Color range: [JPEG]
libva info: VA-API version 1.18.0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/intel-vaapi-driver/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/GL/lib/dri/nvidia_drv_video.so
libva info: va_openDriver() returns -1
[2024:03:13:18:48:46]: Error: Couldn't initialize va display: unknown libva error
[2024:03:13:18:48:46]: Info: SDR color coding [Rec. 601]
[2024:03:13:18:48:46]: Info: Color depth: 8-bit
[2024:03:13:18:48:46]: Info: Color range: [JPEG]
libva info: VA-API version 1.18.0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/intel-vaapi-driver/nvidia_drv_video.so
libva info: Trying to open /usr/lib/x86_64-linux-gnu/GL/lib/dri/nvidia_drv_video.so
libva info: va_openDriver() returns -1
[2024:03:13:18:48:46]: Error: Couldn't initialize va display: unknown libva error
[2024:03:13:18:48:46]: Info: Encoder [vaapi] failed
[2024:03:13:18:48:46]: Info: Trying encoder [software]
[2024:03:13:18:48:46]: Info: Screencasting with X11
[2024:03:13:18:48:46]: Info: SDR color coding [Rec. 601]
[2024:03:13:18:48:46]: Info: Color depth: 8-bit
[2024:03:13:18:48:46]: Info: Color range: [JPEG]
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] using cpu capabilities: MMX2 SSE2Fast SSSE3 SSE4.2
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] profile High, level 4.2, 4:2:0, 8-bit
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] frame I:1     Avg QP:31.00  size:  1203
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] mb I  I16..4: 99.9%  0.0%  0.0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] 8x8 transform intra:0.0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] coded y,uvDC,uvAC intra: 0.0% 0.0% 0.0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] i16 v,h,dc,p: 97%  0%  3%  0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] i8 v,h,dc,ddl,ddr,vr,hd,vl,hu:  0%  0% 75% 12%  0%  0%  0%  0% 12%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] i4 v,h,dc,ddl,ddr,vr,hd,vl,hu:  0%  0% 100%  0%  0%  0%  0%  0%  0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] i8c dc,h,v,p: 100%  0%  0%  0%
[2024:03:13:18:48:46]: Info: [libx264 @ 0x59f3d6be9700] kb/s:577.44
[2024:03:13:18:48:46]: Info: Screencasting with X11
[2024:03:13:18:48:46]: Info: 
[2024:03:13:18:48:46]: Info: // Ignore any errors mentioned above, they are not relevant. //
[2024:03:13:18:48:46]: Info: 
[2024:03:13:18:48:46]: Info: Found H.264 encoder: libx264 [software]
[2024:03:13:18:48:46]: Info: Configuration UI available at [https://localhost:47990]
[2024:03:13:18:48:46]: Info: Adding avahi service Sunshine
[2024:03:13:18:48:47]: Info: Avahi service Sunshine successfully established.
```

Notably the logs showed that Sunshine wasn't able use NVENC or VA-API for encoding,
presumably because of the CUDA errors.

I was able to access the Sunshine web config at `https://localhost:47990`, though,
after accepting a self-signed cert).
I followed the doc link on the web page and eventually ended up at [some instructions](flatpak-install-instructions) for installing
via flatpak that I had previously missed.

[flatpak-install-instructions](https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/setup.html#install)

Following these instructions, I ran `flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine`.

```
$ flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine
Sunshine User Service has been installed.
Use [systemctl --user enable sunshine] once to autostart Sunshine on login.
Configuring mouse permission.
Portal call failed: org.freedesktop.DBus.Error.ServiceUnknown
Restart computer for mouse permission to take effect.
```

I decided to run `systemctl --user enable sunshine` later,
to avoid extra debugging complexity while I troubleshot.

I rebooted the computer as instructed.


I decided I should check to see if Sunshine was working in any capacity.
I installed Moonlight on my laptop and ran Sunshine again.
My game server was not automatically discoverd,
but I added it manually and was able to connect!
Sunshine starts with a few apps preconfigured, including a remote desktop.

To verify that I was using X11 and not Wayland:

```
$ loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
Type=x11
```

```
$ cat /var/lib/flatpak/app/dev.lizardbyte.sunshine/current/active/files/bin/additional-install.sh
#!/bin/sh

# User Service
mkdir -p ~/.config/systemd/user
cp /app/share/sunshine/systemd/user/sunshine.service $HOME/.config/systemd/user/sunshine.service
echo Sunshine User Service has been installed.
echo Use [systemctl --user enable sunshine] once to autostart Sunshine on login.

# Udev rule
UDEV=$(cat /app/share/sunshine/udev/rules.d/60-sunshine.rules)
echo Configuring mouse permission.
flatpak-spawn --host pkexec sh -c "echo '$UDEV' > /etc/udev/rules.d/60-sunshine.rules"
echo Restart computer for mouse permission to take effect.
```

```
$ cat $HOME/.config/systemd/user/sunshine.service
[Unit]
Description=Self-hosted game stream host for Moonlight
StartLimitIntervalSec=500
StartLimitBurst=5
PartOf=graphical-session.target
Wants=xdg-desktop-autostart.target
After=xdg-desktop-autostart.target

[Service]
ExecStart=flatpak run dev.lizardbyte.sunshine
ExecStop=flatpak kill dev.lizardbyte.sunshine
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=xdg-desktop-autostart.target
```

The udev rules file that Sunshine's additional install script should have created didn't appear to exist:

```
$ ls /etc/udev/rules.d/
70-snap.firefox.rules  70-snap.snapd-desktop-integration.rules  70-snap.snapd.rules  70-snap.snap-store.rules
```

Uninstalled the Flathub version of Sunshine:
```
$ flatpak run --command=remove-additional-install.sh dev.lizardbyte.sunshine
$ sudo flatpak uninstall dev.lizardbyte.app.Sunshine
```

Installed Sunshine flatpak from GitHub releases:

```
$ wget https://github.com/LizardByte/Sunshine/releases/download/v0.22.2/sunshine_x86_64.flatpak
$ sudo flatpak install sunshine_x86_64.flatpak
$ flatpak run --command=additional-install.sh dev.lizardbyte.sunshine
Sunshine User Service has been installed.
Use [systemctl --user enable sunshine] once to autostart Sunshine on login.
Configuring mouse permission.
Error creating textual authentication agent: Error opening current controlling terminal for the process (`/dev/tty'): No such device or address
Restart computer for mouse permission to take effect
$ systemctl --user enable sunshine
```

Rebooted.

```
$ sudo reboot now
```

```
$ systemctl --user status sunshine
○ sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/home/drew/.config/systemd/user/sunshine.service; enabled; vendor preset: enabled)
     Active: inactive (dead)
```

```
$ systemctl --user start sunshine
$ systemctl --user status sunshine
● sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/home/drew/.config/systemd/user/sunshine.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2024-03-17 00:57:12 PDT; 3s ago
   Main PID: 1608 (bwrap)
      Tasks: 0 (limit: 4553)
     Memory: 2.8M
        CPU: 10ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/sunshine.service
             ‣ 1608 bwrap --args 40 sunshine
```

```
$ journalctl --user -u sunshine.service
Mar 16 15:35:38 kyoko systemd[1828]: Started Sunshine is a self-hosted game stream host for Moonlight..
Mar 16 15:51:56 kyoko systemd[1828]: sunshine.service: Current command vanished from the unit file, execution of the command list won't be resumed.
Mar 16 18:18:31 kyoko systemd[1828]: Stopping Self-hosted game stream host for Moonlight...
Mar 16 18:18:31 kyoko flatpak[2797]: error: dev.lizardbyte.sunshine is not running
Mar 16 18:18:31 kyoko systemd[1828]: sunshine.service: Control process exited, code=exited, status=1/FAILURE
Mar 16 18:18:31 kyoko systemd[1828]: sunshine.service: Failed with result 'exit-code'.
Mar 16 18:18:31 kyoko systemd[1828]: Stopped Self-hosted game stream host for Moonlight.
-- Boot 63445470c65d4f65b2078a3c59e5b31d --
Mar 17 00:57:12 kyoko systemd[1338]: Started Self-hosted game stream host for Moonlight.
```

## References 

https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/guides/linux/headless_ssh.html
https://unix.stackexchange.com/questions/503806/what-are-x-server-display-and-screen
https://magcius.github.io/xplain/article/index.html
https://www.reddit.com/r/NixOS/comments/12bjfam/comment/jez5d69/
