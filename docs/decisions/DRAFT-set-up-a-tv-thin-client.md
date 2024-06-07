# Set up a TV Thin Client

## Decision

I will set up my Raspbery Pi 4 as a thin client
for streaming from my game server to my TV.

## Consequences

## Context

I like playing games on my living room TV.
To do this for games running on my game server,
I'll need a way to use the TV as a display and a way to handle USB input for a mouse, keyboard, and controller.

I see two options:
1. run HDMI and USB cables directly from my server to the TV
2. stream over ethernet to a thin client connected the TV

There may be more options with a smart TV, but I don't have one.

### Direct connection

A direct connection is the most straightforward, technologically.
It would allow me to use my TV without any other setup.

For running cables, the server and TV are about 20 feet apart.
I would run an HDMI 2.0 cable since my TV only has HDMI 2.0 ports,
and 20 feet is within the max length of passive HDMI 2.0 cables (25 feet).

I would also need to run USB cables to connect peripherals including a mouse, keyboard, and gamepad.
Since these types of USB devices don't transmit that much data I can use USB 2.0.
20 feet is beyond the max length of passive USB 2.0 cables (15 feet).
I would need to get an active USB cable.

To support multiple USB devices I could run multiple USB cables,
but would rather use a USB hub.

### Thin client

A thin client would be computer whose only job is to recieve the stream from the game server and pipe it to the TV.
Setting up a thin client means I have another computer to manage, albeit a small and simple one.

Using a thin client means I will need to interact with two computers to play games.
This adds complexity and more failure points.
It may take longer to open a game because I have to navigate more GUIs, for example.
With some work I could likely minimize the friction this presents.

The thin client would stream the media rather work with the direct output of the GPU like an HDMI cable would.
Streaming uses compression transmits data over the network, so the quality may suffer.
At best I won't be able to tell, but it can never be better than than the signal from a direct connection.
I may see graphical artifacts and unstable latency when streaming, for example.

I already have a Raspberry Pi 4 that has everything I need for a thin client: ethernet, HDMI, and USB ports.
I also already have an ethernet run to my TV, terminated by a small network switch to connect multiple devices.


https://www.youtube.com/watch?v=D0imrHdv88k

https://www.amazon.com/RUIPRO-4K60HZ-HDMI2-0b-Supports-HDCP2-2/dp/B06XGDFCSC?th=1
