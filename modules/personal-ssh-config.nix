{ ... }:
{
  flake.homeModules.personalSshConfig =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          dusty-media-server = {
            HostName = "100.65.171.21";
            User = "drew";
          };
          unremarkable-game-server = {
            HostName = "100.72.211.58";
            User = "drewg";
          };
        };
      };
    };
}
