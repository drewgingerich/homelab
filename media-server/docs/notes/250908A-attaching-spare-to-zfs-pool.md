# Attaching a spare drive to an existing ZFS pool

I have an extra HDD that I'd like to add to my ZFS pool as a hot spare.

Since I previously [added devices to the pool by id](/media-server/docs/notes/250205A-reimporting-zfs-pool-using-device-ids.md),
I'll start by finding the id of the HDD.

```sh
lsblk -o PATH,SIZE,WWN
```
```
PATH         SIZE WWN
/dev/loop0  55.5M
/dev/loop1  55.5M
/dev/loop2  63.8M
/dev/loop3  63.8M
/dev/loop4  91.9M
/dev/loop5  91.9M
/dev/loop6  49.3M
/dev/loop7  50.8M
/dev/sda   232.9G 0x500a0751e1f50c03
/dev/sda1  232.9G 0x500a0751e1f50c03
/dev/sdb     7.3T 0x5000cca0c7d1ba18
/dev/sdc     3.6T 0x50014ee211124089
/dev/sdc1    3.6T 0x50014ee211124089
/dev/sdc9      8M 0x50014ee211124089
/dev/sdd     3.6T 0x50014ee2bbbd3728
/dev/sdd1    3.6T 0x50014ee2bbbd3728
/dev/sdd9      8M 0x50014ee2bbbd3728
/dev/sde     3.6T 0x50014ee2bbbd3ace
/dev/sde1    3.6T 0x50014ee2bbbd3ace
/dev/sde9      8M 0x50014ee2bbbd3ace
/dev/sdf     3.6T 0x50014ee266677aa0
/dev/sdf1    3.6T 0x50014ee266677aa0
/dev/sdf9      8M 0x50014ee266677aa0
```

```sh
ls /dev/disk/by-id/ | grep 0x5000cca0c7d1ba18
```
```
wwn-0x5000cca0c7d1ba18
```

Then I add the HDD to the pool using this id.

```sh
sudo zpool add $POOL_NAME spare wwn-0x5000cca0c7d1ba18
zpool status
```
```
  pool: $POOL_NAME
 state: ONLINE
...
config:

        NAME                        STATE     READ WRITE CKSUM
        $POOL_NAME                  ONLINE       0     0     0
          mirror-0                  ONLINE       0     0     0
            wwn-0x50014ee2bbbd3728  ONLINE       0     0     0
            wwn-0x50014ee266677aa0  ONLINE       0     0     0
          mirror-1                  ONLINE       0     0     0
            wwn-0x50014ee2bbbd3ace  ONLINE       0     0     0
            wwn-0x50014ee211124089  ONLINE       0     0     0
        spares
          wwn-0x5000cca0c7d1ba18    AVAIL

errors: No known data errors
```
