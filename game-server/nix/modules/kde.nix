{ pkgs, ... }:
{
  assertions = [{
    assertion = pkgs.stdenv.isLinux;
    message = "This module is only intended for Linux systems";
  }];

  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = "dreamy";
    };
  };

  services.desktopManager.plasma6.enable = true;
}
