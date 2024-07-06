# Run cables to directly connect server to TV

## Problem

I like playing games on my living room TV.
To do this for games running on my game server,
I need a way to connect the TV and USB inputs (e.g. controller) in the TV area to the server.

## Solution

Run HDMI and USB cables from my server to my TV
so that I can use my TV as a display.

Use a regular 20 foot HDMI cable.

Use an [ezcoo USB-over-ethernet extender](https://www.easycoolav.com/products/usb20-extender-over-cat-5-6-up-to-165ft-4-usb-ports) and a 20 foot ethernet cable for USB.
The price is comperable to an active USB cable + USB hub, it has enough USB ports, and it feels simpler.

## Side-effects

Spend money on the equipment.

Need to drill holes in my walls to run the cables from the basement to the living room on the first floor.

## Context

I see a few options:

1. Move the game server to the TV area
1. Run HDMI and USB cables from the server to the TV
2. Stream from the server to a thin client connected the TV

There may be more options with a smart TV, but I don't have one.

### Moving the server

No.

I think console-style PCs are really cool,
but I've already bought into a rack solution and appreciate its benefits:
noise and heat are not an issue, and it centralizes all of my computers.

### Direct connection

My server and TV are about 20 feet apart.

My TV has HDMI 2.0 ports, so I can run a normal HDMI cable
since 20 feet is within the max length of passive HDMI 2.0 cables (25 feet).

Since I'm only planning on connecting input peripherals---mouse, keyboard, and gamepad---and
these don't transmit much data, I can use USB 2.0.
20 feet is beyond the max length of passive USB 2.0 cables (15 feet),
so I will need some way to extend the connection.
Options include an active USB cable, fiber optics, or USB-over-ethernet. 

https://www.youtube.com/watch?v=D0imrHdv88k.

To support multiple USB devices I could run multiple USB cables,
but a USB hub feels like a cleaner solution.
The USB hub does become a single point of failure for all USB devices.

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
I've sunk 200 hours into Elden Ring streaming from my server to my laptop using and I've enjoyed the experience.
I have seen all of these issues, but they have been small and infrequent enough that I don't mind too much.

