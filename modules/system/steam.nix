{ ... }:
{
  programs.steam.enable = true;

  home-manager.sharedModules = [(
    { config, lib, ... }:
    {
      options.custom.steam.enable = lib.mkEnableOption "Configure Steam for this user";

      config = lib.mkIf config.custom.steam.enable {
        systemd.user.services.steam = {
          enable = true;
          description = "Start Steam Big Screen Mode";
          serviceConfig = {
            ExecStart = "steam -bigscreen";
          };
          wantedBy = [ "graphical-session.target" ];
        };
      };
    }
  )];
}
