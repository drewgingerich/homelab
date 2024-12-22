# Install Cheat Engine for Elden Ring

I want to make a few characters for different PvP builds.
Elden Ring is a massive game and some items and resources require farming.
I don't want to spend a ton of time farming.

## Cheat Engine

[Cheat Engine](https://cheatengine.org/) is a tool that can modify game state,
such as spawning items or unlocking areas.
Cheat Engine is a general tool that can be used on many games.
There is an [Elden Ring Cheat Table](https://github.com/The-Grand-Archives/Elden-Ring-CT-TGA) that provides common operations.

I am mostly following the guide in the [Elden Ring Cheat Table README](https://github.com/The-Grand-Archives/Elden-Ring-CT-TGA/blob/master/README.md).

## How does Wine work?

Cheat Engine is made for Windows.
It can be run on Linux using [Wine](https://www.winehq.org/).

I don't know how Wine works very well
and I like to know roughly what's happening,
so I looked into it a bit.

https://werat.dev/blog/how-wine-works-101/

The CPU instructions in a Windows executable can be run on Linux.
This is because the CPU is at a lower level than the OS and presents the same instruction set in both cases
(assuming both computers have a CPU with the same architecture).

The first problem with running a Windows executable on Linux is that Linux doesn't know how to parse and load the
dynamically-linked libraries the executable relies on.
This is because the Windows executable metadata is in a different format than what Linux expects.
The first thing WINE does is implement a Linux dynamic loader for Windows executables.
When Wine runs a Windows executable, it will parse, find, and load the dynamic libraries it depends on.

The second problem is that while CPU instructions may be the same for Windows and Linux,
the operating system calls are different.
A Windows executable will make Window's system calls, and these are not implemented by Linux.
To solve this, Wine provides a translation layer to convert Windows syscalls to Linux syscalls.
Wine also implements ways to intercept and pipe syscalls through this translation layer.

The third problem is that Windows executables may expect a Windows file hierarchy.
Wine provides a separate Windows file hierarchy in a _Wine prefix_.
This prefix also contains metadata such as Wine configuration files.
Generally each executable run with Wine gets it's own prefix.

The fourth problem is that Windows executables may expect any number of dynamically-linked libraries.
Wine's scope is to only provides DLLs present in a standard Windows installation.
These extra DLLs can be added to the Wine prefix manually.

Steam's [Proton](https://github.com/ValveSoftware/Proton) is Wine with a few modifications and additions to help it run games.

## Installing Wine

To start with I tried Wine for the default package repos:

```
$ sudo apt update
$ sudo apt install wine64
$ wine --version
wine-6.0.3 (Ubuntu 6.0.3~repack-1)
```

Matching what the [Wine docs for installing on Ubuntu](https://wiki.winehq.org/Ubuntu) say,
this installation is three major versions behind stable (Wine v9.0).
This may be just fine, but if something doesn't work then I'll try installing from Wine's package repos.

## Installing Cheat Engine with Wine

I had trouble installing Cheat Engine from [the official Cheat Engine site](https://cheatengine.org/downloads.php).
Instead, I subscribed to the [Cheat Engine Patreon](https://www.patreon.com/cheatengine) for a month to get the latest download.
I don't mind paying a bit to support open-source tools like this.

I downloaded the Cheat Engine installer from the [Cheat Engine GitHub releases](https://github.com/cheat-engine/cheat-engine/releases):

```
$ wget https://github.com/cheat-engine/cheat-engine/releases/download/7.4/CheatEngine74.exe
```

I then ran the installer with Wine, making sure to decline all 3rd party software in the GUI:

```
$ wine CheatEngine74.exe
```

This installed Cheat Engine under `~/.wine`, which is the default prefix location:

```
$ ls "$HOME/.wine/drive_c/Program Files"
'Cheat Engine 7.4'  'Common Files'  'Internet Explorer'  'Windows Media Player'  'Windows NT'
```

The `Cheat Engine 7.4` folder contains 75 files and directories, so the installation involves a lot of pieces.

## Bypassing Easy Anti Cheat (EAC)

EAC is what Elden Ring uses to detect cheating.
Detected cheating results in a soft ban of 180 days.
I really like the online play of Elden Ring, so I don't want this.

While using the Cheat Engine, 

```
$ ls "$HOME/.steam/steam/steamapps/common/ELDEN RING/Game/"
```

Steam launches `start_protected_game.exe` to run the game with EAC.
The game itself is `eldenring.exe`.

Add `eldenring.exe` to Steam as a Non-steam application.





I also downloaded the Elden Ring Cheat Table:

```
$ wget https://github.com/The-Grand-Archives/Elden-Ring-CT-TGA/releases/download/1.9.0/ER_TGA_v1.9.0.zip
$ unzip ER_TGA_v1.9.0.zip
```


https://github.com/cheat-engine/cheat-engine/issues/2725
https://github.com/sonic2kk/steamtinkerlaunch
https://github.com/jcnils/protonhax
