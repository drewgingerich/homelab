{ config, pkgs, lib, ... }:
{
  options.custom.starship.enable = lib.mkEnableOption "Configure Starship for this user";

  config = lib.mkIf config.custom.starship.enable {
    home.packages = with pkgs; [
      starship
    ];

    xdg.configFile = {
      "starship.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/starship/starship.toml";
      };
    };
  };
}
