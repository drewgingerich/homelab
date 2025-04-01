{ pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [
  #   wlx-overlay-s
  # ];

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    config = {
      enable = true;
      json = {
        # application = [ pkgs.wlx-overlay-s ];
        bitrate = 200000000; # 200Mb/s
      };
    };
  };

  home-manager.sharedModules = [(
    { config, lib, pkgs, ... }:
    {
      options.custom.pcvr.enable = lib.mkEnableOption "Configure PCVR for this user";

      config = lib.mkIf config.custom.pcvr.enable {
        xdg.configFile = {
          "systemd/user/graphical-session.target.wants/wivrn.service" = {
            source = "${pkgs.wivrn}/share/systemd/user/wivrn.service";
          };
        };

        # https://wiki.nixos.org/wiki/VR#OpenComposite
        home.packages = [ pkgs.opencomposite ];
        xdg.configFile."openvr/openvrpaths.vrpath".text = ''
          {
            "config": [ "${config.xdg.dataHome}/Steam/config" ],
            "external_drivers": null,
            "jsonid": "vrpathreg",
            "log": [ "${config.xdg.dataHome}/Steam/logs" ],
            "runtime": [ "${pkgs.opencomposite}/lib/opencomposite" ],
            "version": 1
          }
        '';
      };
    }
  )];
}
