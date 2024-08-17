# Set up remote access using Tailscale

I followed the [installation instructions for Debian](https://tailscale.com/kb/1174/install-debian-bookworm),
since Proxmox is heavily based on Debian.

```
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
apt update
apt install tailscale
tailscale up
```

I used [Tailscale Serve](https://tailscale.com/kb/1242/tailscale-serve) to be able to access Proxmox's web UI
with a trusted SSL certificate and on the normal HTTPS port, `443`,
as suggested by Tailscale's [Tailscale on Proxmox host guide](https://tailscale.com/kb/1133/proxmox).

```
NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)"
tailscale cert "${NAME}"
pvenode cert set "${NAME}.crt" "${NAME}.key" --force --restart
tailscale serve --bg https+insecure://localhost:8006
```

Note that I used Tailscale's special `https+insecure` protocol.
I forget if this is necessary or not.
