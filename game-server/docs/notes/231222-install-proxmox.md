# Install Proxmox

I plugged in the bootable USB I [created earlier](./0001-create-bootable-proxmox-usb.md) and started the computer.

On the Proxmox installation screen I selected the graphical install option.

## Keyboard didn't have arrow keys

Proxmox installer uses arrow keys to navigate options,
but my keyboard didn't have any.
Oops!

I added arrow keys to the layout and flashed it.

## Hang while installing drivers

The installation got stuck while installing drivers.

Some Google searching [suggested this happens with Nvidia GPUs](https://www.reddit.com/r/Proxmox/comments/13yx19m/install_help_proxmox_stuck_during_hardware_driver/).

Rebooted to exit the installation process.

Pressed `e` at the installation mode select screen to enter the GRUB menu.

Added `nomodeset` to kernal options line and this step completed.

```
linux  /boot/linux26 ro ramdisk_size=16777216 rw quiet splash=silent nomodeset
```

## Hang while deteting country

The Proxmox installer boot-up process would hang while trying to detect the country.

My guess is that it detected the WiFi card on the Motherboard and figured it had internet access when it didn't.
I couldn't find a way to disable the WiFi card in the BIOS.

I plugged in an ethernet cable to provide internet access and this step completed.

https://forum.proxmox.com/threads/proxmox-installation-trying-to-detect-country.134301/page-2

## Error when starting the installer

When adding the `nomodeset` option in the Grub menu,
I started the installation process directly from there.
This selected the graphical installation by default.

I got an error related to not being able to display the graphics.
I figured this could be because `nomodeset` had disabled them,
and I should just be using the console-based installation process.

I noticed that running the console-based installation process added `proxtui vga=788` to the kernal options,
where I had added `nomodeset`

I added all of these options in the GRUB menu and the installer ran successfully in console mode.

```
linux  /boot/linux26 ro ramdisk_size=16777216 rw quiet splash=silent nomodeset proxtui vga=788
```
