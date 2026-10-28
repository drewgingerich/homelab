{ ... }:
{
  flake.homeModules.wezterm =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wezterm ];

      xdg.configFile = {
        "wezterm" = {
          source = ../dotfiles/wezterm;
          recursive = true;
        };
      };
    };
}
