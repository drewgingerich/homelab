# Re-importing ZFS pool using device IDs

As decided in [media server ADR 240112A](media-server/docs/decisions/240112A-get-a-rack-mounted-case.md),
I got a new rack-mounted case for my media server.

The part I'm worried about transferring is the storage,
and how to make sure the ZFS pool works fine on the other side.

Before anything, I backed up my data to the cloud.
Notably my backups don't include a lot of large media that is replaceable,
such as TV shows, movies, because it's freakin' expensive.
Still, it'd be a pain to lose it.

When I originally made my pool, I used bus-based drive names (e.g. `/dev/sda`) when creating my ZFS pool.

```sh
$ zpool status
...
config:

        NAME        STATE     READ WRITE CKSUM
        $POOL_NAME ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sda     ONLINE       0     0     0
            sdb     ONLINE       0     0     0
          mirror-1  ONLINE       0     0     0
            sdc     ONLINE       0     0     0
            sdd     ONLINE       0     0     0
```

This has been fine so far.

A problem is that when I move the drives to the new case,
they will likely get different bus-based names.
This could cause problems when importing the pool.

This problem can be avoided by using persistent device names,
in particular the `/dev/disk/by-id` names based on the device serial number.

https://wiki.archlinux.org/title/Persistent_block_device_naming#by-id_and_by-path

Before I transfer my computer to the new case, I want to update my pool to
reference devices using the `by-id` names.

https://www.reddit.com/r/zfs/comments/v7u744/replace_device_names_in_pool/

I start by stopping all services that are using the pool.
Take another backup, just for good measure.

Check to make sure no processes are using files in the pool:

```sh
sudo lsof | grep $POOL_NAME
```

No hits, so that's good.

Export the pool:

```sh
sudo zpool export $POOL_NAME
```

Import the pool using `by-id` names:

```sh
sudo zpool import -d /dev/disk/by-id $POOL_NAME
```

ZFS now shows devices with persistent names:

```sh
zpool status
```
```
...
config:

        NAME                        STATE     READ WRITE CKSUM
        $POOL_NAME                 ONLINE       0     0     0
          mirror-0                  ONLINE       0     0     0
            wwn-0x50014ee2bbbd3728  ONLINE       0     0     0
            wwn-0x50014ee266677aa0  ONLINE       0     0     0
          mirror-1                  ONLINE       0     0     0
            wwn-0x50014ee2bbbd3ace  ONLINE       0     0     0
            wwn-0x50014ee211124089  ONLINE       0     0     0
```

I feel ready to move the computer to its new case.

After moving the computer to the new case,
`zpool status` shows that the pool has been imported successfully.
