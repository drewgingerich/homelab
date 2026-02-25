# Troubleshooting slow wifi

WiFi speed should be over 500 Mbps download, but I'm only getting 10.
Discord constantly drops calls.

After a small amount of search, it looked like one possible fix was to update firmware and pray.
I realized I never updated the firmware after setting up this laptop,
so it'd be good to do anyways.

https://community.frame.work/t/very-slow-wifi-and-unstable-speeds-with-new-fw13-hx-370/68725

I enable the `fwupd` service.

```nix
  services.fwupd.enable = true;
```

Then I use `fwupdmgr` to update device firmware.

```sh
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```

There were a few things to update, but none seemed related to the WiFi card.

Looking around, I saw two options:

1. Contact Framework support
2. Try out the Intel AX210 WiFi card that I saw many recommend

The WiFi card was on $14, so I tried that first.
Even if it didn't work, I figured it'd be useful information when talking with support.

And hey, it worked!
Download speed went from 10 to 460 Mbps, which is good enough for me.
