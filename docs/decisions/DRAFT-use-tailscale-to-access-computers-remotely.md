# 8. Use Tailscale to access computers remotely

Date: 2024-02-10

## Status

Pending

## Context

I want to be able to access my computers and services from outside my local network.
I also value strong security and minimal complexity.

### Solution 1: don't

One solution is to just not.
This maximizes security and minimizes complexity.

Remote access is valuable enough to me that this solution doesn't work for me.

### Solution 2: port-forwarding

A second solution is to configure my firewall (which is just my ISP-provided device right now) to forward ports.
This makes the ports accessible from the public internet,
allowing me to access them outside my home network.

Publically exposing ports means I rely on the security of each exposed application to prevent malicious actors from compromising my computers.
I don't trust that every application I run has strong security.

Port-forwarding by itself only allows me to access services using my home network's public IP address.
I have not requested a static IP from my ISP, so my home IP address changes from time to time.
IP addresses are not human-friendly, so it's annoying to remember my home IP address, especially when it changes periodically.

Only being able to use an IP address also means I can't use DNS subdomains to route traffic,
which is my preferred way to route traffic to multiple services that want to listen on the same port.

Using a dynamic DNS client, I can keep a DNS record updated to point at my current home IP address.
This means I only have to remember one domain name and it never changes.
It also allows me to route traffice based on subdomain.

### Solution 3: public proxy

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

### Solution 4: port-forward with access management

- [HCP Boundary](https://www.hashicorp.com/products/boundary)

### Solution 5: virtual private network tunnel

I could use a virtual private network (VPN) tunnel to connect my laptop, phone, and other protable devices to my home computers.

One common approaches include creating a tunnel between my portable devices and a single exit node,
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
- [Nebula](https://github.com/slackhq/nebula)
- [Mistborn](https://gitlab.com/cyber5k/mistborn)

Check out [awesome-tunneling](https://github.com/anderspitman/awesome-tunneling) for more options.

## Decision

Use Tailscale to connect to my servers while not on my home network.

## Consequences

I can connect to my computers from outside of my home network.
The communication is encrypted.

I will need to run the Tailscale daemon on all of my computers.

Tailscale becomes an external service that I rely on.

I get access to all of Tailscale's free-tier features.

- Use my home computers as exit nodes to help secure my internet traffic when I'm away from home.
- Use one of my local computers as a split DNS server.
