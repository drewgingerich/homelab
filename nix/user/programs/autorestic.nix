{ config, pkgs, ... }:
{
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
}
