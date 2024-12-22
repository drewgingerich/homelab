# Expanding VM partition, part 2

Wanted to expand disk [as before](/game-server/docs/log/240314-expand-vm-disk.md).

```sh
$ sudo parted --list
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 550GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size    File system     Name  Flags
 1      2097kB  539MB  537MB   fat32                 boot, esp
 2      539MB   266GB  265GB   ext4            root
 3      266GB   275GB  8988MB  linux-swap(v1)        swap
```

Got error when resizing partition.

```sh
$ sudo parted /dev/sda resizepart 2 100%
Warning: Partition /dev/sda2 is being used. Are you sure you want to continue?
Yes/No? Yes
Error: Can't have overlapping partitions.
```

Thought since there's a swap partition, maybe I can't go all the way to 100%.

```sh
$ sudo parted /dev/sda resizepart 2 90%
Warning: Partition /dev/sda2 is being used. Are you sure you want to continue?
Yes/No? Yes
Error: Can't have overlapping partitions.
```

After some Googling, looked like swap partition is right after main partition,
blocking main partition expansion.
Will have to move swap partition to the end of the disk,
and then expand main partition.

Started by removing swap partition.

```sh
$ sudo swapoff --all
$ sudo parted /dev/sda rm 3
Information: You may need to update /etc/fstab.
$ sudo parted --list
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 550GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name  Flags
 1      2097kB  539MB  537MB  fat32              boot, esp
 2      539MB   266GB  265GB  ext4         root
```

Updated NixOS `hardware-configuration.nix` to not reference deleted swap partition[^1].

```nix
swapDevices = lib.mkForce [ ];
```


Created new swap partition at the end of the drive.

```sh
$ sudo parted /dev/sda
GNU Parted 3.6
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mkpart
Partition name?  []? swap
File system type?  [ext2]? linux-swap
Start? -1GB
End? 100%
$ sudo parted /dev/sda --list
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 550GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name  Flags
 1      2097kB  539MB  537MB  fat32              boot, esp
 2      539MB   266GB  265GB  ext4         root
 3      549GB   550GB  999MB               swap  swap
$ sudo mkswap /dev/sda3
Setting up swapspace version 1, size = 953 MiB (999288832 bytes)
no label, UUID=4275df99-d7d3-4ee6-ad4b-4a80c120f7af
```

Updated NixOS `hardware-configuration.nix` with new swap partition UUID.

```nix
swapDevices = [
  { device = "/dev/disk/by-uuid/4275df99-d7d3-4ee6-ad4b-4a80c120f7af" }
];
```

Expanded main partition.

```sh
$ sudo parted /dev/sda
GNU Parted 3.6
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) resizepart
Partition number? 2
Warning: Partition /dev/sda2 is being used. Are you sure you want to continue?
Yes/No? Yes
End?  [266GB]? -1GB
(parted) print
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 550GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system     Name  Flags
 1      2097kB  539MB  537MB  fat32                 boot, esp
 2      539MB   549GB  548GB  ext4            root
 3      549GB   550GB  999MB  linux-swap(v1)  swap  swap
$ sudo resize2fs /dev/sda2
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/sda2 is mounted on /; on-line resizing required
old_desc_blocks = 31, new_desc_blocks = 64
The filesystem on /dev/sda2 is now 133841920 (4k) blocks long.
```

## Reference

[^1]: https://nixos.wiki/wiki/Swap
