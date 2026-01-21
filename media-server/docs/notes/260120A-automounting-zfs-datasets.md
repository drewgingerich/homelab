# Auto-Mounting ZFS Datasets

When the server reboots, the ZFS volumes are not automatically mounted.
The first time I saw this, for a few minutes,
I was afraid I'd had a catastrophic array failure because there was no data where my pool should be!

I have to manually import the pool:

```sh
sudo zpool import -d /dev/disk/by-id wish
```

NixOS can auto-mount datasets with `mountpoint=legacy`
and specified in the NixOS configuration with `filesystems.<path> = {}`.

Setting `mountpoint=legacy` tells ZFS that the dataset will be mounted with the `mount` command,
instead of ZFS handling the mounting itself.
This is needed for NixOS to take control of the mounting.

The downside is that the NixOS configuration is required to list every dataset.
This is tedious, and can lead to the configuration getting out of sync with the on-disk state.

A second way that NixOS can auto-mount datasets is by adding the pool name to the `boot.zfs.extraPools` option.

The `boot.zfs.extraPools` option tells NixOS to import the provided pools at boot.

The downside here is that for systems using NixOS as root,
this import happens too late for some essential filesystems, e.g. `/nix`, `/etc`.
For these, the legacy mountpoint is the only option.

I want to rely on ZFS to mount the datasets,
so there is a single source of truth.
I am not running ZFS on root, so I don't have to worry about mount order.

I first explore using legacy mount points.

My datasets are not configured with `mountpoint=legacy`.
I verify by checking the mountpoint property of each filesystem:

```sh
zfs get -rt filesystem mountpoint
```

```
NAME           PROPERTY    VALUE           SOURCE
wish           mountpoint  /wish           default
wish/app-data  mountpoint  /wish/app-data  default
wish/config    mountpoint  /wish/config    default
wish/media     mountpoint  /wish/media     default
```

I update the datasets to have `mountpoint=legacy`:

```sh
sudo zfs set mountpoint=legacy wish
zfs list
```

```
NAME            USED  AVAIL  REFER  MOUNTPOINT
wish           3.25T  3.88T  93.7G  legacy
wish/app-data   148G  3.88T   107G  legacy
wish/config     250M  3.88T   250M  legacy
wish/media     3.01T  3.88T  2.81T  legacy
```

I switch back to using normal mount points:

```sh
sudo zfs set mountpoint=/wish wish
zfs list
```

```
NAME            USED  AVAIL  REFER  MOUNTPOINT
wish           3.25T  3.88T  93.7G  /wish
wish/app-data   148G  3.88T   107G  /wish/app-data
wish/config     250M  3.88T   250M  /wish/config
wish/media     3.01T  3.88T  2.81T  /wish/media
```

I add `boot.zfs.extraPools = [ "wish" ];` to my NixOS configuration.

I rebuild and switch NixOS.

I reboot the computer.

And the datasets are automatically mounted!

## Resources

https://toxicfrog.github.io/automounting-zfs-on-nixos/
https://superuser.com/questions/790036/what-is-a-zfs-legacy-mount-point
https://wiki.nixos.org/wiki/ZFS#Importing_on_boot
https://openzfs.github.io/openzfs-docs/man/master/8/zfs-set.8.html
https://discourse.nixos.org/t/zfs-systemd-boot-without-legacy-mountpoints/30789/5
