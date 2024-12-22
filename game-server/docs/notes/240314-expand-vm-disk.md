# Expanding the game server VM disk

When I created the game server VM, I gave it only 32 G of disk space.
I didn't know if I'd need to recreate it, so I kept it light.

32 G of space ran out very quickly.

From my very basic understanding,
increasing the size of the virtual disk doesn't need preparation.
Afterwards, the guest will likely need some configuration to pick up
on the new free space.
Decreasing the size of the virtual disk, on the other hand,
would require more preparation.

I navigated to `Proxmox web UI > VM > Hardware > Hard Disk`.
I selected `Disk Action > Resize`,
and set the increment to bring the disk to 256 G total.

I rebooted the VM.
I don't think this was necessary.

I physically logged into the VM and tried to use Ubuntu's Disks
app to resize the root filesystem to use this additional space,
but I got the following error:

```sh
Error resizing partition /dev/sda2: Failed to set partition size on device
`/dev/sda/ (Unable to satisfy all constraints on the partition.) (udisks-
error-quark, 0)
```

I gave up on the GUI and turned to the commandline
(and SSHed in so I could sit on the couch).

I started by listing the block storage devices.

```sh
$ sudo lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
...
sda      8:0    0   256G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0  31.5G  0 part /
...
```

I then listed the partitions.

```sh
$ sudo parted --list
Warning: Not all of the space available to /dev/sda appears to be used, you can
fix the GPT to use all of the space (an extra 469762048 blocks) or continue with
the current setting?
Fix/Ignore? Fix
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 275GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  538MB   537MB   fat32        EFI System Partition  boot, esp
 2      538MB   34.4GB  33.8GB  ext4
```

`parted` noticed that there was new free space and asked to fix the [GUID Partition Table](gpt-wikipedia).
I accepted.

[gpt-wikipedia]: (https://en.wikipedia.org/wiki/GUID_Partition_Table)

I then expanded the root filesystem partition to take up the free space.

```sh
$ sudo parted /dev/sda resizepart 2 100%
Warning: Partition /dev/sda2 is being used. Are you sure you want to continue?
Yes/No? Yes
Information: You may need to update /etc/fstab.
```

I confirmed by listing the partitions again.
Also the computer didn't crash, always a good sign.

```sh
$ sudo parted --list
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 275GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name                  Flags
 1      1049kB  538MB  537MB  fat32        EFI System Partition  boot, esp
 2      538MB   275GB  274GB  ext4
```

Finally I resized the root filesystem to use the new room in the partition.

```sh
$ sudo resize2fs /dev/sda2
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/sda2 is mounted on /; on-line resizing required
old_desc_blocks = 4, new_desc_blocks = 32
The filesystem on /dev/sda2 is now 66977531 (4k) blocks long.
```

I verified by listing block storage again.

```sh
$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
...
sda      8:0    0   256G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
└─sda2   8:2    0 255.5G  0 part /
```

