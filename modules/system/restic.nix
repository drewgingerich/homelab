{
  pkgs,
  lib,
  config,
  ...
}:

let
  resticScript = pkgs.writeShellScriptBin "restic" ''
    set -euo pipefail

    CREDENTIALS_DIRECTORY=''${CREDENTIALS_DIRECTORY:-/etc/credstore}

    set -a
    source $CREDENTIALS_DIRECTORY/restic.environment
    RESTIC_REPOSITORY_FILE=$CREDENTIALS_DIRECTORY/restic.repository
    RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/restic.password
    set +a

    ${pkgs.restic}/bin/restic $@
  '';
in
{
  options.custom.restic = {
    enable = lib.mkEnableOption "Enable restic backups";
  };

  config = lib.mkIf config.custom.restic.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "This module is only designed for Linux systems";
      }
    ];

    environment.systemPackages = [
      resticScript
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
    #         "restic.b2_bucket_id"
    #         "restic.b2_account_id"
    #         "restic.b2_account_key"
    #         "restic.password"
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
}
