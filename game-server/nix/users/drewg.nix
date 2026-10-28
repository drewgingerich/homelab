{ inputs, pkgs, ... }:
let
  username = "drewg";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    description = "Drew Gingerich";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    initialPassword = username;
  };

  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  home-manager.users.${username} = {
    imports = [
      inputs.self.homeModules.cliTools
      inputs.self.homeModules.fish
      inputs.self.homeModules.starship
    ];

    custom = {
      git.enable = true;
      nvim.enable = true;
      wezterm.enable = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}
