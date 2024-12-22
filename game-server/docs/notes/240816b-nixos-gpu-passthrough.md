After adding the GPU as a PCIe device to the NixOS VM, I was no longer able to connect to Sunshine

Getting the status from systemctl, it looks like the service is inactive.

```sh
$ sudo systemctl --user --machine=steam@ status sunshine
○ sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/etc/systemd/user/sunshine.service; enabled; preset: enabled)
     Active: inactive (dead)
```

I didn't see any logs for the Sunshine service.

```sh
$ sudo journalctl --user --unit sunshine
-- No entries --
```

To see if I got any helpful errors, I tried starting the Sunshine service as the `steam` user.

```sh
$ sudo systemctl --user --machine=steam@ start sunshine
$ sudo systemctl --user --machine=steam@ status sunshine
● sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/etc/systemd/user/sunshine.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-08-16 15:26:33 PDT; 10s ago
   Main PID: 5258
      Tasks: 10 (limit: 28783)
     Memory: 5.1M (peak: 5.9M)
        CPU: 26ms
     CGroup: /user.slice/user-1002.slice/user@1002.service/app.slice/sunshine.service
             └─5258 /run/wrappers/bin/sunshine
```

It looked like Sunshine started successfully, and I saw it become available in my Moonlight client.
Trying to connect gave me an error.

```txt
Host returned error: Failed to initialize video capturing/encoding. Is a display connected and turned on? (Error 503)
```

After a bit of time, the Sunshine service would return to an inactive state.

I checked `journalctl` and saw the following logs.

```sh
$ journalctl -r | less
Aug 16 15:29:11 nixos sunshine[5385]: [2024:08:16:15:29:11]: Fatal: Please check that a display is connected and powered on.
Aug 16 15:29:11 nixos sunshine[5385]: [2024:08:16:15:29:11]: Fatal: Unable to find display or encoder during startup.
Aug 16 15:29:11 nixos sunshine[5385]: [2024:08:16:15:29:11]: Info: Encoder [software] failed
Aug 16 15:29:10 nixos sunshine[5385]: [2024:08:16:15:29:10]: Info: Trying encoder [software]
Aug 16 15:29:10 nixos sunshine[5385]: [2024:08:16:15:29:10]: Info: Encoder [vaapi] failed
Aug 16 15:29:10 nixos sunshine[5385]: [2024:08:16:15:29:10]: Info: Trying encoder [vaapi]
Aug 16 15:29:10 nixos sunshine[5385]: [2024:08:16:15:29:10]: Info: Encoder [nvenc] failed
Aug 16 15:29:09 nixos sunshine[5385]: [2024:08:16:15:29:09]: Info: Trying encoder [nvenc]
Aug 16 15:29:09 nixos sunshine[5385]: [2024:08:16:15:29:09]: Info: // Testing for available encoders, this may generate errors. You can safely ignore those errors. //
```

So it seems like Sunshine is unable to use the GPU and maybe the dummy HDMI plug is not being used as a display.

I tried running `nvidia-smi` to see the GPU status.

```sh
$ nvidia-smi
nvidia-smi: command not found
```

Well, that's problem.

Then I realized I had commented out the [Nvidia driver settings I had added](/game-server/docs/log/240816-nixos-installing-nvidia-drivers.md) to my NixOS configuration. Doh!

Once I uncommented those and rebooted, Sunshine started up and the GPU status was visible.

```sh
$ sudo systemctl --user --machine=steam@ status sunshine
● sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/etc/systemd/user/sunshine.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-08-16 16:25:16 PDT; 6min ago
   Main PID: 1627
      Tasks: 15 (limit: 28783)
     Memory: 121.9M (peak: 156.4M)
        CPU: 7.091s
     CGroup: /user.slice/user-1002.slice/user@1002.service/app.slice/sunshine.service
             └─1627 /run/wrappers/bin/sunshine
$ nvidia-smi
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver. Make sure that the latest NVIDIA driver is installed and running.
```

Connecting with Moonlight connected to a text login prompt rather than the desktop,
and this prompt doesn't appear to accept input.
Notably the prompt specifies `tty1`

If I fullscreen Moonlight to capture all inputs, and hit `ctr+alt+f2`
it switches to a prompt for `tty2` and allows me to login with the `steam` username and password.
This drops me into a terminal sesison.

I am not able to get back to `tty1` by pressing `ctr+alt+f1`.

When I list the user sessions, I see that the `steam` has two sessions
and that the first session is at the login screen.

```sh
$ who
steam    seat0        2024-08-16 16:58 (login screen)
drew     pts/0        2024-08-16 17:00 (123.123.123.123)
steam    tty2         2024-08-16 17:11
```

This is strange because I've configured automatic login for the `steam` user.

Reading the NixOS Nvidia docs more thoroughly,
I saw that it has a troubleshooting section about fixing booting to text mode[^1].
The solution given was to add Nvidia kernel modules manually by adding some NixOs configuration.

```nix
boot.initrd.kernelModules = [ "nvidia" ];
boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
```

This did fix the issue, Sunshine worked, and Moonlight dropped me into a GUI login screen.

It looks like it broke automatic login, but I will leave that for another day.

## Reference

[^1]: https://nixos.wiki/wiki/Nvidia#Booting_to_Text_Mode
