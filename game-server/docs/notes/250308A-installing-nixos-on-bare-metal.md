# Installing NixOS on bare metal

Now that I've [decided to go with a bare metal NixOS installation](/game-server/docs/decisions/250301A-use-nixos.md),
I need to actually install it.

The [NixOS installation guide](https://nixos.wiki/wiki/NixOS_Installation_Guide) is solid.

I download the GNOME, 64-bit Intel/AMD ISO.

I plug in a USB drive to my macbook.

I find the drive with `diskutil list`.

I unmount the drive with `diskutil unmountDisk /dev/disk2`.

I copy the ISO onto the drive with `sudo dd if=path_to_nixos.iso of=/dev/rdisk2 status=progress`.
It takes a while.

I verify the copy with:

```sh
laptop$ export iso_file="nixos-gnome-24.11.715057.5ef6c4259808-x86_64-linux.iso"
laptop$ sudo cmp -n $(stat -f '%z' $iso_file) $iso_file /dev/disk2
```

I eject the drive with `diskutil eject /dev/disk2`.

I connect a monitor, keyboard, and mouse to the server.

I plug the USB into the server.

I SSH into the Proxmox layer.

I list the bootable devices

```sh
server$ efibootmgr
BootCurrent: 0000
Timeout: 1 seconds
BootOrder: 0000,0002,0003
Boot0000* proxmox
Boot0002* UEFI OS
Boot0003* UEFI:  USB DISK 3.0 PMAP
```

I see that the USB is boot 0003.
I set it as the next boot target:

```sh
server$ efibootmgr --nextboot 0003
BootNext: 0003
BootCurrent: 0000
Timeout: 1 seconds
BootOrder: 0000,0002,0003
Boot0000* proxmox
Boot0002* UEFI OS
Boot0003* UEFI:  USB DISK 3.0 PMAP
```

Then I rebooted the computer.

NixOS installation failed because the existing drive couldn't be formatted.

Thinking this might be something to do with the data already on the existing drive, I wiped it:

```sh
installer$ sudo dd if=/dev/zero of=/dev/nvme0n1 status=progress
```

I rebooted the computer and the NixOS installer worked.

I later learned that I could have installed NixOS straight from my flake using:

```sh
nixos-install --flake https://github.com/drewgingerich/homelab#unremarkable-game-server
```

