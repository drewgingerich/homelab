{ ... }:
{
  flake.homeModules.starship =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.starship ];

      xdg.configFile = {
        "starship.toml" = {
          source = ../dotfiles/starship/starship.toml;
        };
      };
    };
}
