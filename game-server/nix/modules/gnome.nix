{ pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.isLinux;
    message = "This module is only intended for Linux systems";
  }];

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "dreamy";

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  # https://discourse.nixos.org/t/stop-pc-from-sleep/5757/2
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  home-manager.sharedModules = [(
    { config, lib, pkgs, ... }:
    {
      options.custom.gnome.noOverview = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Start in desktop view instead of overview";
      };

      config = lib.mkMerge [
        (lib.mkIf config.custom.gnome.noOverview {
          home.packages = [ pkgs.gnomeExtensions.no-overview ];
          dconf.settings = {
            "org/gnome/shell" = {
              enabled-extensions = [
                 "no-overview@fthx"
              ];
            };
          };
        })
      ];

    }
  )];
}
