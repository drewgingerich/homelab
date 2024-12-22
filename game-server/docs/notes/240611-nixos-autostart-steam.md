# Configuring Steam to start on login

I have been using Steam remote play.
This feature requires Steam to be open on the server.
After rebooting the server, I don't want to have to use a remote desktop application to start Steam.
I instead want Steam to open automatically on login.
Paired with the automatic login set up in [240604-nixos-configure-automatic-login](./240604-nixos-configure-automatic-login.md),
this will make Steam start up automatically on boot.


The [Desktop Application Autostart Specification](https://specifications.freedesktop.org/autostart-spec/autostart-spec-latest.html) provides a way to autostart applications.
GNOME implements this specification.
This means I can create a file under `$HOME/.config/autostart` that GNOME will use to start Steam.

This file is a `.desktop` file following the [Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/):

```
[Desktop Entry]
Name=Steam
Type=Application
Exec=/run/current-system/sw/bin/steam
X-GNOME-Autostart-enabled=true
```

This worked!

I would like to manage this autostart file with Home Manager at some point.
