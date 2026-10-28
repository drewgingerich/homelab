{ ... }:
{
  flake.homeModules.fish =
    {
      pkgs,
      osConfig ? null,
      ...
    }:
    {
      assertions = [
        {
          assertion = isNull osConfig || osConfig.programs.fish.enable;
          message = "programs.fish.enable = false in OS config";
        }
      ];

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

  flake.nixosModules.fish =
    { ... }:
    {
      programs.fish.enable = true;
    };

  flake.darwinModules.fish =
    { ... }:
    {
      programs.fish.enable = true;
    };
}
