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

I then ran Sunshine with `flatpak run dev.lizardbyte.app.Sunshine`.
This presented a bunch of errors, though:

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

I was using the default NVIDIA drivers, which I guessed didn't support CUDA.
I knew I should probabaly install the proprietary NVIDIA drivers anyways,
for best performance.

Ubuntu has a command for installing drivers.
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

Since the errors were complaining about not being able to load CUDA,
I also installed CUDA with `sudo apt install nvidia-cuda-toolkit`.

## Running Sunshine

Trying to start Sunshine resulted in the same errors as before. 

