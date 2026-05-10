I have seen a common sentiment on the interwebs that managing GUI applications on macOS with Nix can be troublesome.
I don't have firsthand experience with this, but I already have my hands full learning Nix and don't want to push it.
As an alternative, `nix-darwin` can declaratively manage homebrew:

```nix
{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    casks = [
     "docker"
     "firefox"
     "steam"
     "tailscale"
     "vlc"
     "wezterm"
     # And other GUI applications...
   ];

   # And other config...
 };
```

