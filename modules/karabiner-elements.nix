{ inputs, ... }:
{
  flake.homeModules.karabiner-elements =
    { config, pkgs, ... }:
    {
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

  flake.darwinModules.karabiner-elements =
    { pkgs, ... }:
    {
      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "This module is only intended for Darwin systems";
        }
      ];

      homebrew = {
        enable = true;
        casks = [ "karabiner-elements" ];
      };

      home-manager.sharedModules = [ inputs.self.homeModules.karabiner-elements ];
    };
}
