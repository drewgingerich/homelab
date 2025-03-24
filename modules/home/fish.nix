{ config, pkgs, lib, ... }:
{
  options.custom.fish.enable = lib.mkEnableOption "Enable fish shell for this user";

  config = lib.mkIf config.custom.fish.enable {
    home.packages = with pkgs; [
      fish
    ];

    xdg.configFile = {
      "fish" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/fish";
      };
    };
  };
}
