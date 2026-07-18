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
          settings = {
            dusty-media-server = {
              HostName = "100.65.171.21";
              User = "drew";
            };
            unremarkable-game-server = {
              HostName = "100.72.211.58";
              User = "drewg";
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
