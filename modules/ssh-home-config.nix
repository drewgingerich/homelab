{ inputs, ... }:
{
  flake.homeModules.ssh-home-config =
    { config, lib, ... }:
    {
      options.custom.ssh-home-config.enable = lib.mkEnableOption "SSH Tailnet configuration";

      config = lib.mkIf config.custom.ssh-home-config.enable {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "dusty-media-server" = {
              hostname = "100.65.171.21";
              user = "drew";
            };
            "unremarkable-game-server" = {
              hostname = "100.72.211.58";
              user = "drewg";
            };
          };
        };
      };
    };

  flake.nixosModules.ssh-home-config =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.ssh-home-config ];
    };
}
