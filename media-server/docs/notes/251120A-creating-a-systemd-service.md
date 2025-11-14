# Creating a systemd service

## By hand

I want to start with a user service because it seems easiest to clean up,
and like it has the smallest blast radius.

It seems like running a system service is as simple as omitting the `--user` flag in the `systemctl` calls.

To test out creating a unit file,
I need something to run.

`$HOME/.local/bin/systemd-test.sh`

```sh
set -euo pipefail

while true
do
    now=$(/run/current-system/sw/bin/date)
    me=$(/run/current-system/sw/bin/whoami)
    echo "User $me at $now"
    /run/current-system/sw/bin/sleep 10
done
```

> [!note]
>
> I'm using absolute paths for all the executables in the script
> because NixOS provides a very lean default $PATH that won't find them.

I chose this location according to the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/).

> User-specific executable files may be stored in $HOME/.local/bin.

The `systemd-path` executable also lists this as right spot, from systemd's perspective.

```sh
systemd-path user-binaries
```

```
/home/drew/.local/bin
```

Systemd services are defined by a unit file.

```
$HOME/.config/systemd/user/systemd-test.service
```

```ini
[Unit]

[Install]
WantedBy=default.target

[Service]
Type=simple
ExecStart=/run/current-system/sw/bin/bash /home/.local/bin/systemd-test.sh
```

I verify this is a good spot for it using `systemd-analyze`.

```sh
systemd-analyze --user unit-paths
```

```
/home/drew/.config/systemd/user.control
/run/user/1000/systemd/user.control
/run/user/1000/systemd/transient
/run/user/1000/systemd/generator.early
/home/drew/.config/systemd/user
/etc/xdg/systemd/user
/home/drew/.nix-profile/etc/xdg/systemd/user
/nix/profile/etc/xdg/systemd/user
/home/drew/.local/state/nix/profile/etc/xdg/systemd/user
/etc/profiles/per-user/drew/etc/xdg/systemd/user
/nix/var/nix/profiles/default/etc/xdg/systemd/user
/run/current-system/sw/etc/xdg/systemd/user
/etc/systemd/user
/run/user/1000/systemd/user
/run/systemd/user
/run/user/1000/systemd/generator
/home/drew/.local/share/systemd/user
/home/drew/.nix-profile/share/systemd/user
/nix/profile/share/systemd/user
/home/drew/.local/state/nix/profile/share/systemd/user
/etc/profiles/per-user/drew/share/systemd/user
/nix/var/nix/profiles/default/share/systemd/user
/run/current-system/sw/share/systemd/user
/nix/store/cwyd97h7wf5sprgvpg44j6rjws1bbjkm-systemd-257.9/lib/systemd/user
/run/user/1000/systemd/generator.late
```

I get systemd to pick up on the file by reloading the daemon.

```sh
systemctl --user daemon-reload
```

I verify that system is aware of the new unit file.

```sh
systemctl --user list-unit-files
```

```
UNIT FILE                           STATE    PRESET
dbus-broker.service                 alias    -
dbus.service                        indirect ignored
nixos-activation.service            enabled  ignored
systemd-exit.service                static   -
systemd-test.service                disabled ignored
systemd-tmpfiles-clean.service      static   -
systemd-tmpfiles-setup.service      enabled  ignored
```

I enable the unit.

```sh
systemctl --user enable systemd-test.service
```

```
Created symlink '/home/drew/.config/systemd/user/default.target.wants/systemd-test.service' → '/home/drew/.config/systemd/user/systemd-test.service'.
```

I get the unit's status.

```sh
systemctl --user status systemd-test.service
```

```
○ systemd-test.service
     Loaded: loaded (/home/drew/.config/systemd/user/systemd-test.service; enabled; preset: ignored)
     Active: inactive (dead)
```

I start the unit.

```sh
systemctl --user start systemd-test.service
```

I get the unit's status again.

```sh
systemctl --user status systemd-test
```

```
× systemd-test.service
     Loaded: loaded (/home/drew/.config/systemd/user/systemd-test.service; enabled; preset: ignored)
     Active: failed (Result: exit-code) since Wed 2025-11-19 18:58:19 PST; 3min 39s ago
   Duration: 21ms
 Invocation: fe8b1530c5af4d628a4ad7748c6ae14a
   Main PID: 3969588 (code=exited, status=203/EXEC)
   Mem peak: 1.7M
        CPU: 9ms

Nov 19 18:58:19 dusty-media-server systemd[4153218]: Started systemd-test.service.
Nov 19 18:58:19 dusty-media-server (-test.sh)[3969588]: systemd-test.service: Unable to locate executable '/home/.local/bin/systemd-test.sh': No s>
Nov 19 18:58:19 dusty-media-server (-test.sh)[3969588]: systemd-test.service: Failed at step EXEC spawning /home/.local/bin/systemd-test.sh: No su>
Nov 19 18:58:19 dusty-media-server systemd[4153218]: systemd-test.service: Main process exited, code=exited, status=203/EXEC
Nov 19 18:58:19 dusty-media-server systemd[4153218]: systemd-test.service: Failed with result 'exit-code'.
```

The service failed.
It's because I forgot to add my username in the path to the script.

I update the unit file.

```
$HOME/.config/systemd/user/systemd-test.service
```

```ini
[Unit]

[Install]
WantedBy=default.target

[Service]
Type=simple
ExecStart=/run/current-system/sw/bin/bash /home/drew/.local/bin/systemd-test.sh
```

I restart the systemd daemon to load the updated unit file.

```sh
systemctl --user daemon-reload
```

I restart the service.

```sh
systemctl --user restart systemd-test.service
```

The status looks good.

```sh
systemctl --user daemon-reload && systemctl --user restart systemd-test.service && systemctl --user status systemd-test.service
```

```
● systemd-test.service
     Loaded: loaded (/home/drew/.config/systemd/user/systemd-test.service; enabled; preset: ignored)
     Active: active (running) since Thu 2025-11-20 17:36:30 PST; 20ms ago
 Invocation: 3ecfb55474944a19a551f7a317129b1e
   Main PID: 980720 (bash)
      Tasks: 1 (limit: 76922)
     Memory: 536K (peak: 1.7M)
        CPU: 7ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/systemd-test.service
             ├─980720 /run/current-system/sw/bin/bash /home/drew/.local/bin/systemd-test.sh
             └─980725 /run/current-system/sw/bin/sleep 10

Nov 20 17:36:30 dusty-media-server systemd[4153218]: Started systemd-test.service.
Nov 20 17:36:30 dusty-media-server bash[980720]: User drew at Thu Nov 20 05:36:30 PM PST 2025
```

Nice!

## With NixOS

NixOS provides great support for creating systemd units,
and it'd be a shame not to use it.

I'm less leery of creating a system-level systemd unit if it's managed by NixOS,
since it will be easy to clean up.

I write some NixOS config to create the script and service unit.

```nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "systemd-test.sh" ''
    set -euo pipefail
    while true
    do
         now=$(${pkgs.coreutils}/bin/date)
         me=$(${pkgs.coreutils}/bin/whoami)
         echo "User $me at $now"
         ${pkgs.coreutils}/bin/sleep 10
    done
  '';
in
{
  systemd.services."systemd-test" = {
    enable = true;
    restartIfChanged = true;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = script;
    };
  };
}
```

```sh
sudo nixos-rebuild switch --flake .
```

```sh
sudo systemctl start systemd-test
```

```sh
sudo systemctl status systemd-test
```
```
● systemd-test.service
     Loaded: loaded (/etc/systemd/system/systemd-test.service; linked; preset: ignored)
     Active: active (running) since Sat 2025-11-22 20:08:55 PST; 1min 26s ago
 Invocation: 69f5e4f4010443bf80ec1ea6b259de44
   Main PID: 3350443 (cjdly3hrpgq7753)
         IP: 0B in, 0B out
         IO: 0B read, 0B written
      Tasks: 2 (limit: 76922)
     Memory: 816K (peak: 1.7M)
        CPU: 136ms
     CGroup: /system.slice/systemd-test.service
             ├─3350443 /nix/store/cl2gkgnh26mmpka81pc2g5bzjfrili92-bash-5.3p3/bin/bash /nix/store/cjdly3hrpgq77534p2nlrhr24alc7mna-systemd-test.sh
             └─3351709 /nix/store/00bc157nm93q5fjz551fwk60ihlbilvj-coreutils-9.7/bin/sleep 10

Nov 22 20:08:55 dusty-media-server systemd[1]: Started systemd-test.service.
Nov 22 20:08:55 dusty-media-server cjdly3hrpgq77534p2nlrhr24alc7mna-systemd-test.sh[3350443]: User root at Sat Nov 22 08:08:55 PM PST 2025
Nov 22 20:09:05 dusty-media-server cjdly3hrpgq77534p2nlrhr24alc7mna-systemd-test.sh[3350443]: User root at Sat Nov 22 08:09:05 PM PST 2025
Nov 22 20:09:15 dusty-media-server cjdly3hrpgq77534p2nlrhr24alc7mna-systemd-test.sh[3350443]: User root at Sat Nov 22 08:09:15 PM PST 2025
```

Looks good!

## Resources

https://www.baeldung.com/linux/systemd-create-user-services

https://medium.com/@sebastiancarlos/systemds-nuts-and-bolts-0ae7995e45d3

https://nixos.org/manual/nixpkgs/stable/#trivial-builder-text-writing

https://ertt.ca/nix/shell-scripts/
