{ inputs, pkgs, ... }:
let
  username = "dreamy";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "";
  };

  home-manager.users.${username} = {
    imports = [
      inputs.self.homeModules.cliTools
      inputs.self.homeModules.fish
      inputs.self.homeModules.starship
      inputs.self.homeModules.wezterm
    ];

    custom = {
      git.enable = true;
      nvim.enable = true;
      pcvr.enable = true;
    };

    home.packages = with pkgs; [
      cemu
      xivlauncher
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}
