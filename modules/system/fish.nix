{ ... }:
{
  programs.fish.enable = true;
  home-manager.sharedModules = [ ../home/fish.nix ];
}
