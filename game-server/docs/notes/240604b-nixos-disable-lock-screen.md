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

To check this behavior temporarily I turned off the GNOME screensaver directly:

```
$ gsettings set org.gnome.desktop.screensaver lock-enabled false
$ gsettings get org.gnome.desktop.screensaver lock-enabled
false
```

This worked.

I want to configure this via the NixOS configuration, though.

GNOME settings are stored in a `dconf` database,
and NixOS provides a way to configure these.

https://github.com/NixOS/nixpkgs/pull/234615
https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/dconf.nix
https://discourse.nixos.org/t/need-help-for-nixos-gnome-scaling-settings/24590/11

```
# Disable lock screen.
programs.dconf.profiles.gdm.databases = [{
  settings."org/gnome/desktop/screensaver".lock-enabled = false;
}];
```

I got the settings key from forums and some educated guesswork.
I also learned following can log changed keys while interacting with the GUI:

```
$ dconf watch /
# Go turn off the screensaver in the GUI
/org/gnome/desktop/screensaver/lock-enabled
  false
```

`nixos-rebuild` runs fine (it failed when the key was wrong) but `gsettings` still shows the screensaver as enabled:

```
$ gsettings get org.gnome.desktop.screensaver lock-enabled
true
```

I'm not sure what's happening so I decide to learn more about `gsettings` and `dconf`.

`dconf` is a settings management system that stores key-value pairs in databases.
These databases are in the [GVDB](https://github.com/GNOME/gvdb) binary format.

In a short search, I couldn't find a tool to directly read GVDB database files.

Settings can come from multiple databases.
The set of databases being used is defined in a profile,
which is text file with a newline-delimited list of database identifiers.
The profile used by GDM is located at `/etc/dconf/profile/gdm`:

```
$ cat /etc/dconf/profile/gdm
user-db:user
file-db:/nix/store/f8qk0cpa10ivid264nip7bk75bs26rwh-check-dconf-db
file-db:/nix/store/0dcb532az8bnvabykji220z5vimk728a-dconf-db
```

https://en.wikipedia.org/wiki/Dconf
https://help.gnome.org/admin/system-admin-guide/stable/dconf.html.en
https://wiki.gnome.org/Projects/dconf/SystemAdministrators

Thinking this might be because running `gsettings` set the value in a user database
while the Nix configuration was setting things in a lower-priority system database,
I tried deleting my user database:

```
$ rm $HOME/.config/dconf/user
$ ls $HOME/.config/dconf/

$ gsettings get org.gnome.desktop.screensaver lock-enabled
true
```

This didn't disable the screensaver lock either.

To look at specific databases, I tried to create a dummy profile with a single database id:

```
$ sudo echo user-db:user > /etc/dconf/profile/test
-bash: /etc/dconf/profile/test: Read-only file system
```

This resulted in an error, probably because NixOS makes system files read-only.

```
$ export DCONF_PROFILE=/etc/dconf/profile/gdm
$ dconf read /org/gnome/desktop/screensaver/lock-enabled
true
```

Trying to add write priviledges (temporarily, for testing) confirms this:

```
$ sudo chmod u+w /etc/dconf/profile
chmod: changing permissions of '/etc/dconf/profile': Read-only file system
```

While looking at the [dconf program source code](https://github.com/NixOS/nixpkgs/blob/ffe87a747bc69650ba90d46d01f4068020b389bf/nixos/modules/programs/dconf.nix#L79)
I noticed that there is a `enableUserDb` option.
I set this to false to see if the user database was overriding the setting in the Nix config:

```
  programs.dconf.profiles.gdm = {
    databases = [{
      settings."org/gnome/desktop/screensaver".lock-enabled = false;
    }];
    enableUserDb = false;
  };
```

I can see it did remove the user database identifier from the GDM profile:


```
$ cat /etc/dconf/profile/gdm
file-db:/nix/store/f8qk0cpa10ivid264nip7bk75bs26rwh-check-dconf-db
file-db:/nix/store/0dcb532az8bnvabykji220z5vimk728a-dconf-db
```

Unfortunately `gsettings` still showed the screensaver lock as enabled:

```
$ gsettings get org.gnome.desktop.screensaver lock-enabled
true
```

At this point I wondered if I needed to reboot.
After rebooting, though, `gsettings` still showed screensaver lock enabled.

As another way to get settings values, I used `dconf` to dump all of the entries from the GDM profile:

```
$ DCONF_PROFILE=/etc/dconf/profile/gnome-initial-setup dconf dump /
...
[org/gnome/desktop/screensaver]
lock-enabled=false
...
```

Interestingly this showed that the screensaver lock was disabled.
My conclusion was that `gsettings` is pulling from a different `dconf` database than I expected.

https://askubuntu.com/questions/249887/gconf-dconf-gsettings-and-the-relationship-between-them

I re-enabled the user database in my Nix configuration.

Next I tried reseting the value using `gsettings`:

```
$ gsettings reset org.gnome.desktop.screensaver lock-enabled
```

Screen lock still enabled.

I saw that the `dconf` Nix configuration I used was creating a new `dconf` database and adding it to the GDM profile.
This settings could also be set at the user level (and maybe has to be?).
I saw that [Home Manager](https://github.com/nix-community/home-manager) can edit the user `dconf` database.

https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/

For now I've removed the `programs.dconf` configuration I had added and decided to disable the lock screen using `gsettings` for now.
I've tested and this method survives reboots and NixOS rebuilds.
I don't like that this isn't captured in my NixOS config,
but I want to get something working now and explore Home Manager another time.

