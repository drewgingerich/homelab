
```sh
$ loginctl
SESSION  UID USER  SEAT  TTY   STATE  IDLE SINCE
      1 1002 steam seat0 tty1  active yes  4h 23min ago
      5 1000 drewg -     pts/0 active no   -
$ loginctl show-session 1 -p Type
Type=wayland
```
