# Configure Automatic User Login

I don't want to have to log in when the computer boots.
I want the experience around my game server to be similar to a game console.

In addition to personal preference, Sunshine presents a technical reason to configure automatic login.
Sunshine only starts after user login,
but since I'm using a dummy plug rather than a real monitor
I don't have an easy way to log in if Sunshine isn't running.
The net effect is that I lose access to the computer when I reboot it
until I connect a physical KVM and log in.

My game server is not accessible outside of my local network,
and I'm not worried about anyone on the local network trying to log in.

I check that I'm using GNOME:

```
$ ls /usr/bin/*session
/usr/bin/dbus-run-session  /usr/bin/gnome-session  /usr/bin/gnome-session-custom-session  /usr/bin/pipewire-media-session
# OR
$ gnome-shell --version
GNOME Shell 42.9
```

I add GNOME config to automatically log in my user during boot:

```
$ mkdir /etc/gdm
$ sudo cat << EOF > /etc/gdm/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USER
EOF
```

I reboot the computer.
Automatic login doesn happen and I have to log in with a physical KVM.

I see that `/etc/gdm` doesn't exist and that other instructions on the web specify `/etc/dgm3`.
I see that `/etc/gdm3/custom.conf` already exists on my system.
Looking inside, it has the lines I tried to add commented out and under a `[daemon]` section:

```
[daemon]
# Enabling automatic login
# AutomaticLoginEnable = True
# AutomaticLogin = user1
```

I uncomment the bottom two lines and replace `user1` with my username.
I reboot the computer and it works!
Now when I reboot I don't have to use a physical KVM to log in before Sunshine can start.

I also disabled the lock screen:

```
$ gsettings get org.gnome.desktop.screensaver lock-enabled
true
$ gsettings set org.gnome.desktop.screensaver lock-enabled false
$ gsettings get org.gnome.desktop.screensaver lock-enabled
false
```

## References

https://github.com/LizardByte/Sunshine/issues/1533
https://www.baeldung.com/linux/gnome-disable-screen-lock
