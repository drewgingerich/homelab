{ ... }:
{
  programs.steam.enable = true;

  home-manager.sharedModules = [(
    { config, lib, pkgs, ... }:
    {
      options.custom.steam.enable = lib.mkEnableOption "Configure Steam for this user";

      config = lib.mkIf config.custom.steam.enable {
        systemd.user.services.steam = {
          Unit = {
            Description = "Start Steam in Big Picture mode";
            PartOf = "graphical-session.target";
            After = "graphical-session.target";
          };
          Install.WantedBy = [ "graphical-session.target" ];
          Service.ExecStart = "${pkgs.steam}/bin/steam -bigpicture";
        };
      };
    }
  )];
}
