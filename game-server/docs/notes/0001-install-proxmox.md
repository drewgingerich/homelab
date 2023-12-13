## Create a bootable USB drive

I chose to do things through the command line because I like to know how.
I'm using a mac, so some of the commands are specific to macOS.

1. Download ISO from [the Proxmox download page](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso)
2. Verify checksum with `echo "<SHA256> *<path-to-iso> | shasum -a 256 -c`
3. Find USB device path with `diskutil list`, e.g. `/dev/disk2`
4. Make sure USB device is unmounted with `diskutil unmountDisk <device-path>`
5. Copy ISO onto USB `dd bs=4M if=<path-to-iso> of=<device-path> status=progress`
