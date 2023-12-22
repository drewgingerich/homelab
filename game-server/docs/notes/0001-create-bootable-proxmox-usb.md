# Create a bootable USB drive containing the Proxmox installer

Proxmox has [installation instructions](https://pve.proxmox.com/pve-docs/chapter-pve-installation.html),
but I didn't follow them closely.

I used the command line because I like to know how.
I used a mac, so some of the commands are specific to macOS.

1. Downloaded ISO from [the Proxmox download page](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso)
2. Verified checksum with `echo "<SHA256> *<path-to-iso> | shasum -a 256 -c`
3. Found USB device path with `diskutil list`, e.g. `/dev/disk2`
4. Made sure USB device is unmounted with `diskutil unmountDisk <device-path>`
5. Copied ISO onto USB `dd bs=4M if=<path-to-iso> of=<device-path> status=progress`
