{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    wezterm
  ];

  xdg.configFile = {
    "wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/wezterm";
    };
  };
}
