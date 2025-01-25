# Browsing files in a ZFS snapshot

Recently I noticed that all the data for Actual budget had disappeared.
Going back through ZFS snapshots seemed like the easiest way to find the data.

To start, I listed the snapshots:

```sh
$ zfs list -t snapshot
NAME                                      USED  AVAIL     REFER  MOUNTPOINT
wish@zrepl_20240704_031329_000            144K      -     93.7G  -
...
wish/app-data@zrepl_20240628_091327_000  1.63G      -     72.0G  -
...
wish/config@zrepl_20240629_061328_000       0B      -      250M  -
...
wish/media@zrepl_20240701_151328_000     59.3G      -     1.87T  -
...
```

Good, lots of snapshots going back 6 or 7 months.
I did notice that there appeared to be a few different datasets.
Yes I set this up, but it had been a long time since I'd revisited my ZFS setup.

I verified that the application data was stored in its own dataset:

```sh
$ zfs list
NAME            USED  AVAIL     REFER  MOUNTPOINT
wish           2.71T  4.42T     93.7G  /wish
wish/app-data  91.7G  4.42T     72.0G  /wish/app-data
wish/config     250M  4.42T      250M  /wish/config
wish/media     2.52T  4.42T     2.42T  /wish/media
```

ZFS snapshots are browsable by looking in the `.zfs` folder at the root of the dataset.
Since I'm looking at the `wish/app-data` dataset, I look under `/wish/app-data/.zfs`:

```sh
$ ll /wish/app-data/.zfs/snapshot/zrepl_20241222_161356_000/actual

total 0
```

...and nothing shows up. I try it for a different app:

```sh
$ ll /wish/app-data/.zfs/snapshot/zrepl_20241222_161356_000/filebrowser/
total 9.0K
drwxr-xr-x 4 drew drew 5 Apr  2  2022 config
drwxr-xr-x 2 drew drew 3 Apr  2  2022 database
```

That works.
It was at this point I realized that I didn't set up values correctly for Actual Budget,
and the data was getting wiped every time the container restarted.
A lesson to double check the files that should exist actually do exist.
