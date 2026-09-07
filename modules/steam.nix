{ ... }:
{
  flake.nixosModules.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };
    programs.gamemode.enable = true;
  };
}
