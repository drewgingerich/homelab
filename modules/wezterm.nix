{ inputs, ... }:
{
  flake.homeModules.wezterm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.custom.wezterm.enable = lib.mkEnableOption "WezTerm";

      config = lib.mkIf config.custom.wezterm.enable {
        home.packages = with pkgs; [
          wezterm
        ];

        xdg.configFile = {
          "wezterm" = {
            source = ../dotfiles/wezterm;
            recursive = true;
          };
        };
      };
    };

  flake.nixosModules.wezterm =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.wezterm ];
    };
}
