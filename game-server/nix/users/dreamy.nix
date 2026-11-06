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
      inputs.self.homeModules.git
      inputs.self.homeModules.nvim
      inputs.self.homeModules.starship
      inputs.self.homeModules.wezterm
    ];

    custom = {
      pcvr.enable = true;
    };

    home.packages = with pkgs; [
      cemu
      itgmania
      limo
      melonds
      mgba
      openmw
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}
