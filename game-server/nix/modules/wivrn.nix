{ config, pkgs, ... }:
let
  wivrn_svc = config.systemd.user.services.wivrn;
  # wivrn_app_svc = config.systemd.user.services.wivrn-application;
in
{
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
  };
  environment.systemPackages = [ pkgs.monado-vulkan-layers ];
  hardware.graphics.extraPackages = [ pkgs.monado-vulkan-layers ];

  home-manager.sharedModules = [(
    { config, lib, ... }:
    {
      options.custom.wivrn.enable = lib.mkEnableOption "Configure WiVRn for this user";

      config = lib.mkIf config.custom.wivrn.enable {
        systemd.user = {
          enable = true;
          services.wivrn = wivrn_svc // {
            wantedBy = [ "default.target" ];
          };
          # services.wivrn-app = wivrn_app_svc;
        };
      };
    }
  )];
}
