# Use Tailscale to access computers remotely

## Problem

I want to be able to remotely SSH into and access applications on my servers,
with strong security and minimal complexity.

I am choosing not to consider how to provide access to others right now,
as that's a more complicated problem.

## Options

1. Simply do not
2. Port-forwarding
3. Reverse proxy
4. Virtual private network (VPN)

## Solution

Use Tailscale to set up a VPN for remotely accessing services.

## Side effects

I can remotely access my services.
Transferred data is end-to-end encrypted.

I will need to run the Tailscale daemon on all of my computers.

Tailscale becomes an external service that I rely on.

I get access to Tailscale's other free-tier features.

## Context

### Option 1: Simply do not

Having no remote access maximizes security and minimizes complexity.

Remote access is valuable enough to me that I can't accept this solution.

### Option 2: Port forwarding

I could expose expose services outside of my home network by configuring my router to forward ports to my servers.

This means I'd rely on the security of each exposed service.
I don't trust that every service I want to use remotely use has strong security.
My assumption is actually the opposite: probably none of my self-hosted services are very secure.

### Option 3: Reverse proxy

I could set up a proxy server with a public IP that forwards traffic to my home computers.

I'm hand waving how the proxy connects to my servers.

While my servers would not be directly exposed to the public internet,
using a proxy like this would still indirectly expose them.
There's some extra obscurity, but I run into the same core security issues as port-forwarding.

### Option 4: Virtual private network (VPN)

This would put all of my portable devices and servers into one virtual network,
whilst keeping them private from the public internet.

OpenVPN and WireGuard appear to be the most common VPN technologies for homelab use.
Wireguard is newer and more popular, and is purportedly faster and simpler.
Wireguard has been adopted into the Linux kernal,
which makes me trust that it lives up to its reputation.

I could configure connections by hand,
but I've been using [Tailscale](https://tailscale.com/) to handle this for me instead.
Tailscale provides coordination servers to establish WireGuard peer-to-peer connections
to create a virtual mesh network that allows all my devices to talk directly to each other[^1].
I like it a lot: setup has been fast and simple,
it's available everywhere I've looked (e.g. my iPhone), and it has never given me trouble.

Tailscale also offers a lot of other features,
and I appreciate their thorough documentation.
I guess I'm a bit of a Tailscale shill.

Using Tailscale does introduce a reliance on the coordination server.
All of my traffice is end-to-end encrypted, so I'm not worried about Tailscale reading my data.
Tailscale also has an open-source variant of its coordination server called [Headscale](https://github.com/juanfont/headscale),
which softens my worries about vendor lock in.

While I am already using Tailscale and satisfied with it for personal remote access,
it's not the only solution out there;
[awesome-tunneling](https://github.com/anderspitman/awesome-tunneling) lists many other options.

[^1]: https://tailscale.com/blog/how-tailscale-works
