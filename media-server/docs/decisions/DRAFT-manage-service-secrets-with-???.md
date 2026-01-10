# Manage service secrets with ???

## Problem

I need a way to provide services with secrets, such as API keys.

## Options

1. Manage secrets outside of Nix
  1. Encrypted files
  2. Secrets manager
2. Manage secrets inside of Nix
  1. [agenix](https://github.com/ryantm/agenix)
  2. [sops-nix](https://github.com/Mic92/sops-nix)

## Decision

## Exploration

Services can get secrets in three ways:

1. Environment variables
2. Reading files
3. Making a network request to a secret management service

Putting secrets in environment variables is not preferred, since environment variables 

## Bookmarks

https://www.reddit.com/r/NixOS/comments/17vejd0/handling_secrets_in_nixos_an_overview_gitcrypt/
https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/
https://fzakaria.com/2024/07/12/nix-secrets-for-dummies

https://dee.underscore.world/blog/systemd-credentials-nixos-containers/
https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Environment
https://systemd.io/CREDENTIALS/
> Use LoadCredential=, LoadCredentialEncrypted= or SetCredentialEncrypted= (see below) to pass data to unit processes securely.

https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

