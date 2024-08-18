# Setting the resolution of a dummy HDMI plug

I bought a [dummy HDMI plug from Adafruit](https://www.adafruit.com/product/4247)
so that I didn't have to keep a monitor connected to be able to use Sunshine.

Dummy plug worked in place of a real monitor right away, but default resolution is 4k.
This was too big for me.

To work with the dummy display I had to use a real display connected to the server to get a graphical session.

Checked dummy plug available resolutions.

```sh
$ xrandr -q
...
HDMI-0 connected primary 3840x2160+0+0 (normal left inverted right x axis y axis) 344mm x 195mm
   3840x2160     59.98*+  59.94    50.00    29.97    25.00    23.98  
   4096x2160     59.94    50.00    29.97    25.00    24.00    23.98  
   1920x1080    120.00   100.00    60.00    60.00    59.94    50.00    29.97    25.00    23.98  
   1440x900      59.89  
   1400x1050     59.98  
   1280x1024     75.02    60.02  
   1280x960      60.00  
   1280x720      60.00    59.94    50.00  
   1024x768      75.03    70.07    60.00  
   800x600       75.00    72.19    60.32    56.25  
   640x480       75.00    72.81    59.94  
...
```

Set display to 1080p.

```sh
$ xrandr --output HDMI-0 --mode 1920x1080 
```

Much easier to look at, but there was no sound. 

Restarted Sunshine unit.

```sh
$ systemctl restart --user sunshine
```

Sound works!

## References 

[What are X server, display and screen? (Stack Exchange)](https://web.archive.org/web/20230724161409/https://unix.stackexchange.com/questions/503806/what-are-x-server-display-and-screen)
[Explanations (X tutorial series)](https://web.archive.org/web/20240219064511/https://magcius.github.io/xplain/article/index.html)
