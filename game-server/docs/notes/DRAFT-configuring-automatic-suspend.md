# Configuring automatic suspend

I don't want this computer to suspend when:

- I am SSHed in
- I am using a keyboard, mouse, or controller
- I am watching a video or listening to music
- Plex is running

It seems that automatic suspend on Linux only looks for keyboard and mouse activity by default,
and that it can be difficult to prevent automatic suspension for SSH, video, and audio activity.

https://wiki.archlinux.org/title/Power_management

Since I'll be running Plex constantly, this is all a moot point:
I don't want this system to suspend ever.
It has a hybrid role between a desktop PC and a server.

I try to disable automatic suspend with the display manager option:

```nix
services.xserver.displayManager.gdm.autoSuspend = false;
```

The system still suspends.

I brute force it by disabling the systemd targets related to suspension:

```nix
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;
```

This works, but I get a notification every so often that the system will suspend,
even though it can't.
Good enough for now!

https://help.gnome.org/users/gnome-help/stable/power-autosuspend.html.en
