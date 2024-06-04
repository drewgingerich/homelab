# NixOS: Disable lock screen

In addition to setting up automatic login in [240604-nixos-configure-automatic-login](./240604-nixos-configure-automatic-login.md),
I want to disable the lock screen so I never have to unlock the computer.
I'm trying to get the console experience.
Adding the following to my `/etc/nix/configuration.nix` made this happen:

```
services.xserver.xautolock.enable = false;
```

I also came across this option:

```
services.xserver.displayManager.gdm.autoSuspend = false;
```

I'm not using it right now, but I want to look at this more and understand it.
If I can get a suspended state from inactivity but still avoid the lock screen then I think that's ideal,
and I believe that's what I have with `xautolock` disabled and `autoSuspend` enabled.
