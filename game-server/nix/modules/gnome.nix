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

  services.xserver.displayManager.gdm.autoSuspend = false;

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
      home.packages = with pkgs; [
        gnomeExtensions.no-overview
        gnomeExtensions.notification-timeout
      ];
      dconf.settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "no-overview@fthx"
            "notification-timeout@chlumskyvaclav.gmail.com"
          ];
        };
      };
    }
  )];
}
