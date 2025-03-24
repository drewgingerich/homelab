{ config, pkgs, lib, ... }:
{
  options.custom.wezterm.enable = lib.mkEnableOption "Configure WezTerm for this user";

  config = lib.mkIf config.custom.wezterm.enable {
    home.packages = with pkgs; [
      wezterm
    ];

    xdg.configFile = {
      "wezterm" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/wezterm";
      };
    };
  };
}
