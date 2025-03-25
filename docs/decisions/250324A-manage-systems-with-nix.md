# Manage systems with Nix

Informed by [game-server/250301A: Use NixOS](/game-server/docs/decisions/250301A-use-nixos.md).

## Problem

I want to manage my computer systems in a way that:

1. Defines system state in a version-controlled configuration file
2. Defines system state completely and explicitly
3. Reproduces system state in a robust fashion
4. Prevents system state drift

## Solution

Use Nix and related tools, such as [NixOS](https://nixos.org/),
[nix-darwin](https://github.com/LnL7/nix-darwin),
and [Home Manager](https://github.com/nix-community/home-manager),
to manage my computer systems.

## Context

I have 2 macOS laptops (personal and work), a game server, and a media server.
In the past I have maintained them all separately.

I have really enjoyed using NixOS to manage the game server.

Who am I kidding, I'm already using Nix for everything
and this is a bit of a retroactive ADR.
