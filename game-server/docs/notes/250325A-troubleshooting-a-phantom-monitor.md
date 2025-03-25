# Troubleshooting a phantom monitor

I am trying to get [WlxOverlay-S](https://github.com/galister/wlx-overlay-s) to work.
I am seeing the watch and keyboard UI, but not the desktop.

The WlxOverlay-S [known issues docs](https://github.com/galister/wlx-overlay-s?tab=readme-ov-file#known-issues)
brings up a phantom monitor as a possible issue.

I list the monitors:

```sh
$ xrandr -q
Screen 0: minimum 16 x 16, current 1920 x 1080, maximum 32767 x 32767
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 1600mm x 900mm
```

The `HDMI-1` monitor is expected, but `Screen 0` is not.

After poking around the internet a bit, I learned that `Screen 0` is actually expected.
A screen is an abstraction over one or more monitors,
and the `Screen 0` resolution matching the `HDMI-1` resolution suggests things are working fine.

https://askubuntu.com/questions/981609/select-screen-0-with-xrandr

## Other reading

https://wiki.archlinux.org/title/Xrandr#Disabling_phantom_monitor
https://github.com/NixOS/nixpkgs/issues/321603#issuecomment-2188410213
https://www.reddit.com/r/linux4noobs/comments/dx5dze/xrandr_shows_two_displays_when_i_only_use_one/

