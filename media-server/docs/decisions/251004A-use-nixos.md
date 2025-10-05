# Use NixOS

## Problem

I'm struggling to maintain my media server with the level of control that I want.
I don't like setting up systemd units (e.g. creating database dumps and backing them up to cloud storage)
separately from the Docker services they support.
After years of package and OS updates, the filesystem has gotten crufty and I no longer understand the state of the system.

## Solution

Use NixOS.

## Exploration

NixOS ticks all of my boxes for improving the maintainability of my server.
I have really enjoyed [using NixOS for my game server](/game-server/docs/decisions/250301A-use-nixos.md),
and I'm deferring here to that decision record for a more in-depth analysis of why.

