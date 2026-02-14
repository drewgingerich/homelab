{ lib, config, ... }:
{

  options.custom.restic = {
    enable = lib.mkEnableOption "Enable restic backups";
  };

  options.custom.restic.backups = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            passwordFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            environmentFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            repositoryFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
            };

            paths = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
        }
      )
    );
    default = { };
  };

  config = lib.mkIf config.custom.backups.enable {
    services.restic.backups.photos = {
      repositoryFile = "/etc/credstore/restic.repository";
      passwordFile = "/etc/credstore/restic.password";
      environmentFile = "/etc/credstore/restic.repo_creds";
      paths = [ "/wish/media/photos" ];
      timerConfig = {
        OnCalendar = "00:05";
        Persistent = true;
        RandomizedDelaySec = "6h";
      };
    };
  };
}
