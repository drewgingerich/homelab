{ config, lib, pkgs, ... }:
{
  options.custom.karabiner.enable = lib.mkEnableOption "Configure Karabiner Elements for this user";

  config = lib.mkIf config.custom.karabiner.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "This module is only intended for Darwin systems";
      }
    ];

    xdg.configFile = {
      "karabiner" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/karabiner";
      };
    };
  };
}
