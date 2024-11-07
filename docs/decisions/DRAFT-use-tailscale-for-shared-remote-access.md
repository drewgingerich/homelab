# Use Tailscale to access computers remotely

## Problem

I want to be able to remotely SSH into and access applications on my servers,
with strong security and minimal complexity.

I am choosing not to consider how to provide access to others right now,
as it's more complicated.

## Options

1. Don't
2. Configure my router's firewall to forward ports to my server
3. Proxy server
   - [Caddy](https://github.com/caddyserver/caddy)
   - [Traefik](https://github.com/traefik/traefik)
   - [NGINX Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
   - [rinetd](https://github.com/samhocevar/rinetd)
   - [frp](https://github.com/fatedier/frp)
   - [boringproxy](https://github.com/boringproxy/boringproxy)
4. Use a VPN tunnel
   - [Tailscale](https://tailscale.com/)
   - [Headscale](https://github.com/juanfont/headscale)
   - [ZeroTier](https://www.zerotier.com/)
   - [Netmaker](https://netmaker.readthedocs.io/en/master/index.html)
   - [Netbird](https://netbird.io/)
   - [Nebula](https://github.com/slackhq/nebula)
   - [Mistborn](https://gitlab.com/cyber5k/mistborn)

## Solution

Use Tailscale to connect to my servers while not on my home network.

## Side effects

I can connect to my computers from outside of my home network.
The communication is encrypted.

I will need to run the Tailscale daemon on all of my computers.

Tailscale becomes an external service that I rely on.

I get access to all of Tailscale's free-tier features.

- Use my home computers as exit nodes to help secure my internet traffic when I'm away from home.
- Use one of my local computers as a split DNS server.

## Context

### Option 1: don't

One solution is to just not.
This maximizes security and minimizes complexity.

Remote access is valuable enough to me that this solution doesn't work for me.

### Option 2: firewall port-forwarding

I can configure my firewall to forward ports to my servers to expose applications to the public internet.

I would rely on the security of each exposed application to prevent malicious actors from compromising my computers.
I don't trust that every application I want to remotely use has strong security.
Exposing SSH access is especially concerning to me.

### Option 3: public proxy

A third solution is to use a publicly-accessible proxy server to forward traffic to my home computers.
This means my home computers are not directly exposed to the public internet,
but can be accessed indirectly through the proxy.

Public traffic can still reach my services.

Reverse proxy possibilities include:

- [Caddy](https://github.com/caddyserver/caddy)
- [Traefik](https://github.com/traefik/traefik)
- [NGINX Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
- [rinetd](https://github.com/samhocevar/rinetd)
- [frp](https://github.com/fatedier/frp)
- [boringproxy](https://github.com/boringproxy/boringproxy)
- [Teleport](https://goteleport.com/)
- [HCP Boundary](https://www.hashicorp.com/products/boundary)
- [Cloudflare WARP](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/)

### Option 4: virtual private network tunnel

I could use a virtual private network (VPN) tunnel to connect my laptop, phone, and other protable devices to my home computers.

A common approach is to create a tunnel between my portable devices and a single exit node,
letting my portable devices access my home network remotely.

Another is to create a direction connection between each device, known as a mesh network.
or a single

OpenVPN and Wireguard appear to be the most common VPN technologies for homelab use.
Wireguard is faster and more lightweight.
Wireguard has been adopted into the Linux kernal,
which makes me trust its quality more than OpenVPN.
I also appreciate that the Wireguard codebase is much smaller OpenVPN's.

Making direct VPN connections
I don't want to deal

I could use a virtual private server (VPS) to proxy traffic to my home computers.
This adds an extra layer between the public internet and my home computers.
The VPS would need to be able to find and connect to my home computers.
and use a virtual private network

- [Tailscale](https://tailscale.com/)
- [Headscale](https://github.com/juanfont/headscale)
- [ZeroTier](https://www.zerotier.com/)
- [Netmaker](https://netmaker.readthedocs.io/en/master/index.html)
- [Netbird](https://netbird.io/)
- [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/)
- [Nebula](https://github.com/slackhq/nebula)
- [Mistborn](https://gitlab.com/cyber5k/mistborn)

Check out [awesome-tunneling](https://github.com/anderspitman/awesome-tunneling) for more options.
