# Configure restic backups

There is currently no `nix-darwin` module for restic.
Since I only want to back up my `$HOME/data` directory,
it feels like it fits well as a Home Manager configuration anyways.

Install Restic and Autorestic:

```nix
  home.packages = with pkgs; [
    restic
    autorestic
  ];
```

```nix


