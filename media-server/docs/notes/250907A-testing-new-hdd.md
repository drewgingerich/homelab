# Testing a new HDD

I want to make sure that the new HDD I have is working well before I start putting data on it.

After some looking around, it seems that a combination of
[SMART](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology) and
[Badblocks](https://en.wikipedia.org/wiki/Badblocks) is the most common method.

The procedure I'll go with is:

1. Run Badblocks
2. Run SMART long test

[TrueNAS Forum: Hard Drive Burn-in Testing](https://www.truenas.com/community/resources/hard-drive-burn-in-testing.92/)
[S.M.A.R.T. – Short, Extended and Conveyance Self-Tests](https://ipfail.org/useful/s-m-a-r-t-short-extended-and-conveyance-self-tests/)

I see that `badblocks` and `smartctl` are already installed:

```sh
$ type badblocks
badblocks is /usr/sbin/badblocks
$ type smartctl
smartctl is /usr/sbin/smartctl
```

I believe `badblocks` is installed on my machine by default,
and I previously installed [smartmontools](https://help.ubuntu.com/community/Smartmontools) for `smartctl`.

To figure out the drive path, I get some information using `lsblk`:

```sh
$ lsblk -o PATH,SIZE,SERIAL,WWN
PATH         SIZE SERIAL          WWN
/dev/loop0  50.8M
/dev/loop1  55.5M
/dev/loop2  63.8M
/dev/loop3  91.9M
/dev/loop4  91.9M
/dev/loop5  55.5M
/dev/loop6  49.3M
/dev/loop7  63.8M
/dev/sda   232.9G 1913E1F50C03    0x500a0751e1f50c03
/dev/sda1  232.9G                 0x500a0751e1f50c03
/dev/sdb     7.3T VY17ZWWM        0x5000cca0c7d1ba18
/dev/sdc     3.6T WD-WCC7K3PZZAYR 0x50014ee211124089
/dev/sdc1    3.6T                 0x50014ee211124089
/dev/sdc9      8M                 0x50014ee211124089
/dev/sdd     3.6T WD-WCC7K7LC0X0D 0x50014ee2bbbd3728
/dev/sdd1    3.6T                 0x50014ee2bbbd3728
/dev/sdd9      8M                 0x50014ee2bbbd3728
/dev/sde     3.6T WD-WCC7K2KDEVAD 0x50014ee2bbbd3ace
/dev/sde1    3.6T                 0x50014ee2bbbd3ace
/dev/sde9      8M                 0x50014ee2bbbd3ace
/dev/sdf     3.6T WD-WCC7K7LC0CDT 0x50014ee266677aa0
/dev/sdf1    3.6T                 0x50014ee266677aa0
/dev/sdf9      8M                 0x50014ee266677aa0
```

The drive at `/dev/sdb` is the one I want,
because it's the only 8TB drive.
I could look at the serial number on the drive to be sure,
but I'm feeling lazy and don't want to pull it out.
I do compare to the output of `zpool status` to double check that it's not part of my ZFS pool.

Badblocks only runs as a foreground application and runs for a long time,
so I'll need to use a multiplexer like tmux to keep my shell session alive.

Calling tmux by itself starts a session:

```sh
$ tmux
```

For large devices (>2TB) it appears that the block size should be manually specified as 4096 when running Badblocks.

```sh
$ tmux
$ sudo badblocks -ws -b 4096 /dev/sdb
```

I disconnect from the tmux session with the default tmux hotkey sequence of `ctrl+b d`.
I reattach to the latest session by running `tmux a` to check on progress.

It takes about 4 days to finish, and no errors are detected!

```sh
$ tmux a
$ sudo badblocks -ws -b 4096 /dev/sdb
Testing with pattern 0xaa: done
Reading and comparing: done
Testing with pattern 0x55: done
Reading and comparing: done
Testing with pattern 0xff: done
Reading and comparing: done
Testing with pattern 0x00: done
Reading and comparing: done
```

I kill the tmux session with ` tmux kill-session -t 0`.

Next I run a SMART long test:

```sh
sudo smartctl -t long /dev/sdb
```
```
...
Please wait 830 minutes for test to complete.
```

Now I wait again.

After it finishes, I check the results with:

```sh
sudo smartctl -a /dev/sdb
```
```
...
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000b   100   100   016    Pre-fail  Always       -       0
  2 Throughput_Performance  0x0004   133   133   054    Old_age   Offline      -       93
  3 Spin_Up_Time            0x0007   100   100   024    Pre-fail  Always       -       0
  4 Start_Stop_Count        0x0012   100   100   000    Old_age   Always       -       4
  5 Reallocated_Sector_Ct   0x0033   100   100   005    Pre-fail  Always       -       0
  7 Seek_Error_Rate         0x000a   100   100   067    Old_age   Always       -       0
  8 Seek_Time_Performance   0x0004   128   128   020    Old_age   Offline      -       18
  9 Power_On_Hours          0x0012   100   100   000    Old_age   Always       -       5123
 10 Spin_Retry_Count        0x0012   100   100   060    Old_age   Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       4
192 Power-Off_Retract_Count 0x0032   078   078   000    Old_age   Always       -       27167
193 Load_Cycle_Count        0x0012   078   078   000    Old_age   Always       -       27167
194 Temperature_Celsius     0x0002   187   187   000    Old_age   Always       -       32 (Min/Max 18/38)
196 Reallocated_Event_Count 0x0032   100   100   000    Old_age   Always       -       0
197 Current_Pending_Sector  0x0022   100   100   000    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0008   100   100   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x000a   200   200   000    Old_age   Always       -       0
...
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Extended offline    Completed without error       00%      5120         -
```

These results look good: The status of the extended offline test is `Completed without error`.

Since both Badblocks and the SMART long test passed,
this drive appears healthy and ready to be used!

