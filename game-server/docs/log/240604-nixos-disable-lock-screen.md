# NixOS: Disable lock screen

In addition to setting up automatic login in [240604-nixos-configure-automatic-login](./240604-nixos-configure-automatic-login.md),
I want to disable the lock screen so I never have to unlock the computer.
I'm trying to get the console experience.

Based on internet searches, I added the following to my `/etc/nix/configuration.nix`:

```
services.xserver.xautolock.enable = false;
```

Unfortunately after some inactivity a login screen requiring a password still appeared.

To check if `xautolock` is running with and without this config I ran:

```
$ pgrep xautolock
```

In both cases I got no response, indicating `xautolock` was not active.

I didn't have a good understanding of how lock screens worked in Linux,
so I did a little research.

https://linux.die.net/man/1/xautolock
https://wiki.archlinux.org/title/Session_lock#xautolock
https://www.baeldung.com/linux/display-managers-explained

I realized that my configuration had GDM enabled,
which was the same setup I was using for the Ubuntu VM:

```
services.xserver.displayManager.gdm.enable = true;
```

This meant the lock screen behavior was probably managed by GDM.
Indeed:

```
$ gsettings get org.gnome.desktop.screensaver lock-enabled
true
```

To check this behavior temporarily I turned off disable the GNOME screensaver:

```
$ gsettings set org.gnome.desktop.screensaver lock-enabled false
$ gsettings get org.gnome.desktop.screensaver lock-enabled
false
```



https://github.com/NixOS/nixpkgs/issues/54150

https://github.com/DavHau/nixos-steam-box

