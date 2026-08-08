{ ... }: {
  flake.nixosModules.forgejo =
    { config, ... }:
    {
      # networking.nat = {
      #   enable = true;
      #   internalInterfaces = [ "ve-+" ];
      #   externalInterface = "ens0";
      # };

      containers.forgejo = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.100.10";
        localAddress = "192.168.100.11";
        config =
          {
            lib,
            ...
          }:
          {

            services.forgejo = {
              enable = true;
            };

            networking = {
              firewall.allowedTCPPorts = [ 80 ];

              # Use systemd-resolved inside the container
              # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
              useHostResolvConf = lib.mkForce false;
            };

            services.resolved.enable = true;

            system.stateVersion = config.system.stateVersion;
          };
      };
    };
}
