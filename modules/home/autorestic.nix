{ config, pkgs, lib, ... }:
{
  options.custom.autorestic.enable = lib.mkEnableOption "Enable autorestic backups for this user";

  config = lib.mkIf config.custom.autorestic.enable {
    assertions = [{
      assertion = pkgs.stdenv.isDarwin;
      message = "This module is only configured for Darwin systems";
    }];

    home.packages = with pkgs; [
      autorestic
      restic
    ];

    launchd = {
      agents = {
        autorestic = {
          enable = true;
          config = {
              ProgramArguments = [
                "${pkgs.autorestic}/bin/autorestic"
                "backup" "--all" "--ci"
                "--restic-bin" "${pkgs.restic}/bin/restic"
              ];
              StartCalendarInterval = [{
                Hour = 5;
                Minute = 0;
              }];
              StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stderr.log";
              StandardOutPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stdout.log";
          };
        };
      };
    };
  };
}
