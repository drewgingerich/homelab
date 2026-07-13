{ inputs, ... }:
{
  flake.homeModules.starship =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.custom.starship.enable = lib.mkEnableOption "Starship";

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
    };

  flake.nixosModules.starship =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.starship ];
    };
}
