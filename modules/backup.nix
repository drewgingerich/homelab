{ ... }: {
  flake.nixosModules.backup =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      restic-systemd-exec = pkgs.writeShellApplication {
        name = "restic-systemd-exec";
        runtimeInputs = with pkgs; [
          restic
          toybox # Needed for xargs
        ];
        text = ''
          export RESTIC_REPOSITORY_FILE=$CREDENTIALS_DIRECTORY/restic.repository
          export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/restic.password
          export RESTIC_CACHE_DIR=/var/cache/restic
          # shellcheck disable=SC2046
          export $(systemd-creds cat restic.environment | xargs)
          restic "$@"
        '';
      };
      wrestic = pkgs.writeShellApplication {
        name = "wrestic";
        runtimeInputs = [ restic-systemd-exec ];
        text = ''
          systemd-run --pipe --wait --quiet --property 'ImportCredential=restic.*' restic-systemd-exec "$@"
        '';
      };
    in
    {
      options.custom.backups = lib.mkOption {
        type =
          with lib.types;
          attrsOf (submodule {
            options = {
              paths = lib.mkOption {
                type = listOf str;
                default = [ ];
              };
              excludes = lib.mkOption {
                type = listOf str;
                default = [ ];
              };
            };
          });
        default = { };
      };

      config = {
        environment.systemPackages = [
          wrestic
        ];

        systemd.services = lib.mapAttrs' (
          name: backup:
          let
            joinedPaths = lib.concatStringsSep " " backup.paths;
            joinedExcludes = lib.concatStringsSep " " (
              lib.map (x: "--exclude ${x}") backup.excludes
            );
          in
          lib.nameValuePair "backup-${name}" {
            enable = true;
            restartIfChanged = false;
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              ImportCredential = "restic.*";
              ExecStart = "${restic-systemd-exec}/bin/restic-systemd-exec backup ${joinedPaths} ${joinedExcludes}";
            };
          }
        ) config.custom.backups;

        systemd.timers = lib.mapAttrs' (
          name: backup:
          lib.nameValuePair "backup-${name}" {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
            };
            unitConfig.X-OnlyManualStart = true;
          }
        ) config.custom.backups;
      };
    };
}
