{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom.backups = lib.mkOption {
    description = "Configure periodic backups.";
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            passwordFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = ''
                Read the repository password from a file.
              '';
              example = "/etc/nixos/restic-password";
            };

            environmentFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = ''
                file containing the credentials to access the repository, in the
                format of an EnvironmentFile as described by {manpage}`systemd.exec(5)`
              '';
            };

            inhibitsSleep = lib.mkOption {
              default = false;
              type = lib.types.bool;
              example = true;
              description = ''
                Prevents the system from sleeping while backing up.
              '';
            };

            repositoryFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
              description = ''
                Path to the file containing the repository location to backup to.
              '';
            };

            paths = lib.mkOption {
              # This is nullable for legacy reasons only. We should consider making it a pure listOf
              # after some time has passed since this comment was added.
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = [ ];
              description = ''
                Which paths to backup, in addition to ones specified via
                `dynamicFilesFrom`.  If null or an empty array and
                `dynamicFilesFrom` is also null, no backup command will be run.
                 This can be used to create a prune-only job.
              '';
              example = [
                "/var/lib/postgresql"
                "/home/user/backup"
              ];
            };
          };
        }
      )
    );
    default = { };
  };

  config = lib.mkIf config.custom.backup.enable {

    home.packages = with pkgs; [
      autorestic
      restic
    ];

    services.restic.backups.foo = {

    };
  };
}
