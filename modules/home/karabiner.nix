{ config, pkgs, lib, ... }:
{
  options.custom.karabiner.enable = lib.mkEnableOption "Configure Karabiner for this user";

  config = lib.mkIf config.custom.karabiner.enable {
    assertions = [{
      assertion = pkgs.stdenv.isDarwin;
      message = "This module is only configured for Darwin systems";
    }];

    xdg.configFile = {
      "karabiner" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/karabiner";
      };
    };
  };
}
