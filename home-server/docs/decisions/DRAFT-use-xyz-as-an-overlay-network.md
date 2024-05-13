# 23. Use XYZ as an overlay network

Date: 2023-11-30

## Status

Accepted

## Context

### Problem

I want:

- to provide access to services from outside my local network
- strong security
- minimal complexity

### Potential solutions

Solutions include:

- Don't
- Port-forward on router with dynamic DNS
- Port-forward using reverse proxy on VPS
- Overlay network

### Port-forward with dynamic DNS

### Reverse proxy

Reverse proxy possibilities include:

- Caddy
- Traefik
- NGINX Proxy Manager
- [frp](https://github.com/fatedier/frp)
- [boringproxy](https://boringproxy.io/)

### Overlay network

Overlay network possibilities include:

- [Tailscale](https://tailscale.com/)
- [Headscale](https://github.com/juanfont/headscale)
- [Netmaker](https://netmaker.readthedocs.io/en/master/index.html)
- [Netbird](https://netbird.io/)
- [Nebula](https://github.com/slackhq/nebula)
- [Mistborn](https://gitlab.com/cyber5k/mistborn)

Check out [awesome-tunneling](https://github.com/anderspitman/awesome-tunneling) for more options.

### Access management

- [HCP Boundary](https://www.hashicorp.com/products/boundary)

## Decision

The change that we're proposing or have agreed to implement.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.
