# 6. Build a game server

Date: 2023-08-10

## Status

Pending

## Context

I want to play modern Indie games only released on Windows, such as Valheim.

I want to run emulators up to XBox, Gamecube, and PS2.

I want to using streaming services that do not have a native PS5 or Smart TV app, such as Shudder and Dropout, using a browser.

I want to play modded versions of last-gen games such as Skyrim and Fallout 4.

I want to view this media on my TV.
As a bonus it would be cool to be able to stream remotely to my laptop.

I have a PlayStation 5, a Nintendo Switch, and a macOS laptop.

I want to play games that are not available on my existing devices.
These are mostly Indie games only released on Windows.
Some are games that are exclusive to XBox and PC.

I also want to play modded versions of some games.
These are mostly AAA games, such as Skyrim.

An XBox will play the XBox-exclusive games.
It won't play Windows-only Indie games unless they are also released seperately on XBox.
It won't play games that are released exclusively on the PC.
As far as I can tell, all XBox-exclusive games are available on PC.
The XBox does not support modding most games.

A computer running Windows will let me play these games.
A computer running Linux might also let me play these games, using Steam's [Proton](<https://en.wikipedia.org/wiki/Proton_(software)>) feature or by configuring [Wine](<https://en.wikipedia.org/wiki/Wine_(software)>) myself.

My laptop has Windows installed as well, using Bootcamp.
I don't like how long it takes to switch between operating systems.
I rarely using Windows on my laptop because of this.

I prefer to play games on the couch using a controller.

There is technology for low-latency remote game streaming.
[Moonlight](https://moonlight-stream.org/)([Moonlight GitHub organization](https://github.com/moonlight-stream)) and [Sunshine](https://app.lizardbyte.dev/Sunshine/?lng=en) ([Sunshine GitHub repository](https://github.com/LizardByte/Sunshine)) can stream applications, including Steam, and a full desktop.
[Steam Link](https://en.wikipedia.org/wiki/Steam_Link) can stream games from Steam.

Cloud gaming services present another option.
[Nvidia GeForce Now](https://www.nvidia.com/en-us/geforce-now/) and [XBox Cloud Gaming](https://www.xbox.com/en-us/play) appears to be the two major players.
These options appear to be cheaper than building a computer.
The top tier subscription for GeForce Now is $20 a month.
This

The game selection and ability to mod games is limited.
Neither offer other benefits of a PC, such as internet browsing.

I also want a way to view TV streaming services from the couch that don't have native PS5 or smart TV apps,
such as [Shudder](<https://en.wikipedia.org/wiki/Shudder_(streaming_service)>) and [Dropout](<https://en.wikipedia.org/wiki/Dropout_(streaming_platform)>).

Some streaming applications on console or smart TVs are not as polished as their web equivalents.
It would be nice to be able to stream media to the TV using the web view, rather than the native application.

## Decision

I will build a computer for game and application streaming to my other devices.

## Consequences

This computer will use Windows or Linux.

I will need to research and purchase parts for the computer.

I will need to maintain the computer's hardware, software, and data.
