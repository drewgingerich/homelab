{ inputs, ... }:
{
  flake.homeModules.karabiner-elements =
    { pkgs, ... }:
    {
      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "Only works on Darwin";
        }
      ];

      xdg.configFile = {
        "karabiner" = {
          source = ../dotfiles/karabiner;
        };
      };
    };

  flake.nixosModules.keyboard =
    { ... }:
    {
      services.keyd = {
        enable = true;
        keyboards = {
          default = {
            ids = [ "*" ];
            settings = {
              main = {
                capslock = "overload(nav, esc)";
              };
              nav = {
                h = "left";
                j = "down";
                k = "up";
                l = "right";
              };
            };
          };
        };
      };
    };

  flake.darwinModules.keyboard =
    { ... }:
    {
      homebrew = {
        enable = true;
        casks = [ "karabiner-elements" ];
      };

      home-manager.sharedModules = [ inputs.self.homeModules.karabiner-elements ];
    };
}
