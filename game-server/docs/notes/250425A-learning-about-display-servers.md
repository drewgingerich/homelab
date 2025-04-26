# Learning about display servers

In the era of room-sized computers, terminals were stations where users could interact with the computer.
There would be multiple terminals for each computer,
allowing multiple people to use the computer at the same time.

While computers are much smaller and often have a single user today,
the history of terminals is still visible.
Instead of a physical terminal, we now use software terminal emulators
to mimic (and evolve) the terminal experience.

An old type of terminal was the teletyper.
Instead of a screen, the teletyper would print the output.
The word "teletype" has been abbreviated to _TTY_,
which is now sometimes used to refer to a terminal emulator.

Somewhat arbitrarily, most Linux distributions automatically set up 7 TTYs.
The active TTY can be switched using hotkeys, or by running:

```sh
$ sudo chvt <tty_num>
```

Starting these TTYs appears to be managed by systemd with `/etc/systemd/system/getty@.service`.

https://www.reddit.com/r/linuxquestions/comments/oikda1/what_the_hell_is_tty/
https://www.reddit.com/r/linux4noobs/comments/wi7axu/what_are_the_multiple_ttys_in_linux_for/

To get a graphical environment, a display server needs to be started.
The display server provides an interface over hardware including screens, keyboards, and mice.
GUI applications can use this interface to handle user input and show graphics.

GUI applications could interact with hardware themselves instead of relying on a display server,
but the display server provides a stable abstraction over various types hardware,
which allows app developers to focus on their app instead of reimplementing hardware interactions.

https://www.tuxfiles.org/linuxhelp/xwtf.html

While a user could log into a TTY and start the display server themselves,
a display manager is usually used to handle this.
The display manager is responsible for starting the display server and presenting a graphical login screen.

It looks like the display manager is managed by systemd with `/etc/systemd/system/display-manager.service`

https://www.baeldung.com/linux/display-managers-install-uninstall
https://itsfoss.com/display-manager/
https://wiki.archlinux.org/title/Display_manager

The two main display servers are X and Wayland.
These are actually protocols, with various concrete implementations.

https://www.reddit.com/r/linuxquestions/comments/3uh9n9/what_exactly_is_xxorgx11/

While the display server gives app a window,
it does not by default provide a way to manipulate this window (resize, move, fullscreen, etc.).
A window manager is a piece of software that provides these features.
A window manager is itself a client of the display server.

https://www.media.mit.edu/wearables/mithril/anduin/window_manager.html

A Wayland server acts as a window manager in addition to a display server.
Separate window managers can also be used with Wayland.

A desktop environment is a collection is a bundle of all sorts of things to make a complete GUI system,
such as:

- a display manager
- a window manager
- bundled applications such as a calculator, word processor, browser, etc.
- screensaver
- graphical utilities for various settings
- start menu
- dock

Using a desktop environment is convenient, but it's possible to use graphical Linux without one.

