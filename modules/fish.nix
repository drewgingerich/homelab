{ inputs, ... }:
{
  flake.homeModules.fish =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.custom.fish.enable = lib.mkEnableOption "Fish shell";

      config = lib.mkIf config.custom.fish.enable {
        home.packages = with pkgs; [
          fish
        ];

        xdg.configFile = {
          "fish" = {
            source = ../dotfiles/fish;
            recursive = true;
          };
        };
      };

    };

  flake.nixosModules.fish =
    { ... }:
    {
      programs.fish.enable = true;
      home-manager.sharedModules = [ inputs.self.homeModules.fish ];
    };
}
