# Configuring autorestic

I like to use [restic](https://restic.net/) for backups.

There is currently no `nix-darwin` or Home Manager module for restic,
though there is [nix-community/home-manager issue 5009](https://github.com/nix-community/home-manager/issues/5009) to
implement a Home Manager module.
Since I only want to back up my `$HOME/data` directory,
it feels like it fits well as a Home Manager configuration anyways.

Install restic and Autorestic:

```nix
  home.packages = with pkgs; [
    restic
    autorestic
  ];
```

```nix


