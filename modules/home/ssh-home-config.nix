{ config, lib, ... }:
{
  options.custom.ssh-home-config.enable = lib.mkEnableOption "Configure SSH client to connect to home network resources via Tailnet";

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
}
