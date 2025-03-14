{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    starship
  ];

  xdg.configFile = {
    "starship.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/starship/starship.toml";
    };
  };
}
