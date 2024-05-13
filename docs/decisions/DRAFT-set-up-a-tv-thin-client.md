# 9. Set up a TV Thin Client

Date: 2024-03-21

## Status

Pending

## Context

I like playing games on my living room TV.
To do this for games running on my game server,
I'll need a way to use the TV as a display and a way to handle USB input for a mouse, keyboard, and controller.

I see two options: run an HDMI and USB cables from server to the TV,
or stream to a thin client next to the TV over ethernet.
There may be more options with a smart TV, but I don't have one.


I have a Raspberry Pi 4 that has everything I need for a thin client: ethernet, HDMI, and USB ports.
Streaming uses compression
and can produce artifacts, latency, and stuttering.
I would also have to maintain the Raspberry Pi. 

For running cables, the server and TV are about 20 feet apart.

I would run an HDMI 2.0 cable since my TV only has HDMI 2.0 ports.
20 feet is under the max length of passive HDMI 2.0 cables (25 feet),
so I could use a passive cable. 

Since I only need to use a mouse and keyboard USB devices, I can use USB 2.0.
20 feet is beyond the max length of passive USB 2.0 cables (15 feet).
I would need to get an active USB extender.
To support multiple USB devices, I would need to use a 

While my GPU has an HDMI 2.1 port, my TV only has an HDMI 2.0 port.
This limites the potential HDMI bandwidth to 18 Gbps.
This is still much faster than my 1 Gbps ethernet cables.

A direct HDMI connection potentially avoids issues related to streaming artifacts,
since streaming is a more complex process.




A direct HDMI connection can make use of the HDMI 2.0 18 Gbps, while my ethernet cables are only 1 Gbps.


As a direct connection, this should get the best performance.
While my TV only has HDMI 2.0, I would prefer to get an HDMI 2.1 cable for future-proofing
since my GPU provides an HDMI 2.1 port.
Long HDMI cables need to be active optical cables,
and appear to be around $50 right now.


I have a Raspberry Pi 4 that I'm not using.
The Raspberry Pi 4 has an ethernet port, and HDMI 2.0 port, and two USB 3.0 ports,
so it has all the connectivity needed to be a thin client.
While the HDMI 2.0 limits the resolution and refresh rate
compared to the HDMI 2.1 port on the GPU,
my TV only supports HDMI 2.0 anyways.

https://www.youtube.com/watch?v=D0imrHdv88k

https://www.amazon.com/RUIPRO-4K60HZ-HDMI2-0b-Supports-HDCP2-2/dp/B06XGDFCSC?th=1


## Decision

I will set up my Raspbery Pi 4 as a thin client
for streaming from my game server to my TV.

## Consequences

