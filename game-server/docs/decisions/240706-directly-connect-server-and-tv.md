# Run cables to directly connect server to TV

## Problem

I want to play games on my living room TV while running them on my server.

## Options

1. Move the game server to the TV area and connect via HDMI
2. Run HDMI and USB cables from the server to the TV
3. Stream from the server to a thin client connected the TV

## Solution

Run HDMI and USB cables from my server to my TV
so that I can use my TV as a display.

Use a regular 20 foot HDMI cable.

Use an [ezcoo USB-over-ethernet extender](https://www.easycoolav.com/products/usb20-extender-over-cat-5-6-up-to-165ft-4-usb-ports) and a 20 foot ethernet cable for USB.
The price is comperable to an active USB cable + USB hub, it has enough USB ports, and it feels simpler.

## Side-effects

Spend money on the equipment.

Need to drill holes in my walls to run the cables from the server to the living room.

## Context

My TV is not a smart TV, so it can't stream games from the server.
In order to play games, I'll need a way to get the AV to the TV,
and to connect USB devices in the living room to the server.

### Moving the server

No.

I think console-style PCs are really cool,
but I've already bought into a rack solution and appreciate its benefits:
noise and heat are not an issue, and it centralizes my computer hardware.

### Direct connection

My server and TV are about 20 feet apart.

My TV has HDMI 2.0 ports, so I can run a normal HDMI cable
since 20 feet is within the max length of passive HDMI 2.0 cables (25 feet).

Since I'm only planning on connecting input peripherals---mouse, keyboard, and gamepad---and
these don't transmit much data, I can use USB 2.0.
20 feet is beyond the max length of passive USB 2.0 cables (15 feet),
so I will need some way to extend the connection.
Options include an active USB cable, fiber optics, or USB-over-ethernet[^1]. 

### Thin client

I already have ethernet running between my server and TV area.

I already have a Raspberry Pi 4 that has everything I need for a thin client: ethernet, HDMI, and USB ports.

A thin client is another computer to manage,
and introduces more points of failure:
at least the network, the thin client's OS, and the streaming software.

Using a thin client means needing to interact with two computers to play games,
which adds friction.

Streaming software introduces a few potential issues:

- stuttering and lag due to network issues
- visual artifacts due to compression, such as banding in dark images
- latency

Streaming software is pretty great these days.
I've sunk 200 hours into Elden Ring streaming from my server to my laptop using Moonlight and Sunshine and I've enjoyed the experience.
I have seen all of these issues, but they have been small and infrequent enough that I don't mind too much.

[^1]: https://www.youtube.com/watch?v=D0imrHdv88k
