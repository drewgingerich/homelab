{ ... }:
{
  flake.nixosModules.containers =
    { ... }:
    {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
      };
    };

  flake.darwinModules.containers =
    { ... }:
    {
      homebrew = {
        enable = true;
        brews = [ "colima" ];
      };
    };
}
