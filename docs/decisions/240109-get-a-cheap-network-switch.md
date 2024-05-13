# 6. Get a cheap network switch

Date: 2024-01-09

## Status

Accepted

## Context

I need more ethernet ports than my router provides.
I need only one additional port right now,
but I'd like a few extra for future expansion.

I'd like the switch to be located at the server rack,
so I don't need to run cables far for equipment on the rack.
There are rack-mounted switch options, generally starting at 16 ports.

Switches can be catagorized as unmanaged, smart, or managed.

Unmanged switches provide more connectivity without additional features.

Smart switches provide additional features such as VLANS, QoS, and port speed monitoring.
These features are exposed through a web GUI.

Managed switches provide even more features such as monitoring and access control,
designed for enterprise environments.
These features are exposed via a commandline.
Some features and information are also often exposed via a web GUI as well.

I only need additional connectivity at this time.
I am interested in exploring other features for science if the price is not much higher.

Switches can provide ports of different speeds.
Common options include 10/100 Mb/s, 1 Gb/s, and 10 Gb/s.
In order to make full use of a port's speed,
connected devices must have network cards capable of that speed
My computers have 1 Gb/s NICs.
10 Gb/s comes at a high price premium.

Switches can also provide power over ethernet (PoE),
allowing low-powered devices to be powered and networked with a single ethernet cable.
I don't have any PoE devices right now.
PoE comes at a high price premium.

## Decision

Buy a TL-SG108E 8-port gigabit desktop smart switch for $30.

## Consequences

I get the additional connectivity I need.

I don't have a switch with advanced features or PoE on hand, if I need them in the future.

I save money by buying a small and simple switch.

## References

- [Managed vs Unmanaged vs Smart Switch: What Are the Differences?](https://web.archive.org/web/20231101225047/https://community.fs.com/article/managed-vs-unmanaged-vs-smart-switch-what-are-the-differences.html)
- [An Affordable Managed Switch to Learn Networking](https://www.youtube.com/watch?v=hsRYJ2evJVQ&t=674s)
- [Network Switches & Ethernet - Home Networking 101](https://www.youtube.com/watch?v=xeOOTpyLT8Y)
