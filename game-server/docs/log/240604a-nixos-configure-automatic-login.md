# NixOS: Configuring automatic login

I want to set up automatic login like I did for Ubuntu in [240324-configure-automatic-login](./240324-configure-automatic-login.md).
This was just two lines of configuration in `/etc/nix/configuration.nix`:

```
services.xserver.displayManager.autoLogin.enable = true;
services.xserver.displayManager.autoLogin.user = "<username>";
```

Bam, works like a charm. So easy!

I'm using X11, but it appears there may be some issues with autologin when using GNOME with Wayland on NixOS.
I came across [this issue comment](https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229) with an explanation and workaround:

```
# Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
systemd.services."getty@tty1".enable = false;
systemd.services."autovt@tty1".enable = false;
```

I'm leaving this here for my future self, since I want to check out Wayland at some point.

