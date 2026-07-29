{ ... }: {
  flake.nixosModules.backup =
    { pkgs, ... }:
    let
      backup-run = pkgs.writeShellApplication {
        name = "backup-run";
        runtimeInputs = with pkgs; [
          restic
          toybox
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
      rr = pkgs.writeShellApplication {
        name = "rr";
        runtimeInputs = [
          pkgs.restic
          backup-run
        ];
        text = ''
          systemd-run --pipe --wait --quiet --property 'ImportCredential=restic.*' backup-run "$@"
        '';
      };
    in
    {
      # options.custom.restic = {
      #   paths =
      #     with lib.types;
      #     listOf submodule {
      #       include = listOf str;
      #       exclude = listOf str;
      #       preScript = str;
      #       postScript = str;
      #     };
      # };

      config = {
        environment.systemPackages = [
          backup-run
          rr
        ];

        # systemd.services."restic-backup-creds" =
        #   let
        #     paths = [
        #       # "/wish/app-data"
        #       # "/wish/media/home-video"
        #       # "/wish/media/pictures"
        #       "/etc/credstore"
        #     ];
        #     host = "media-server";
        #
        #     # Surround each path in quotes to handle whitespace, then join into one string
        #     formatted_paths = builtins.concatStringsSep " " (builtins.map (x: "\"${x}\"") paths);
        #
        #     restic_backup_script = pkgs.writeShellScript "run_restic_backup_creds.sh" ''
        #        set -euo pipefail
        #
        #        export RESTIC_REPOSITORY="$(cat $CREDENTIALS_DIRECTORY/restic.repository)";
        #        export B2_ACCOUNT_ID="$(cat $CREDENTIALS_DIRECTORY/restic.b2_account_id)";
        #        export B2_ACCOUNT_KEY="$(cat $CREDENTIALS_DIRECTORY/restic.b2_account_key)";
        #
        #        export RESTIC_PASSWORD_FILE="$CREDENTIALS_DIRECTORY/restic.password";
        #
        #       ${pkgs.restic}/bin/restic backup ${formatted_paths} --host "${host}"
        #     '';
        #   in
        #   {
        #     enable = true;
        #     restartIfChanged = false;
        #     wants = [ "network-online.target" ];
        #     after = [ "network-online.target" ];
        #     serviceConfig = {
        #       Type = "oneshot";
        #       LoadCredential = [
        #         "restic.repository"
        #         "restic.password"
        #         "restic.environment"
        #       ];
        #       ExecStart = "${pkgs.bash}/bin/bash ${restic_backup_script}";
        #     };
        #   };
        #
        # systemd.timers."restic-backup" = {
        #   enable = true;
        #   wantedBy = [ "timers.target" ];
        #   timerConfig = {
        #     OnUnitActiveSec = "5m";
        #     # OnCalendar=Mon..Fri *-*-* 10:00:*
        #     Unit = "restic-backup.service";
        #   };
        # };
      };
    };
}
