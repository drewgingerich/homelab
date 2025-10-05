{ pkgs, ... }:
let
  username = "drew";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    description = "Drew Gingerich";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
    initialPassword = "password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSbdj21C9TuxPMcE1xWOIr/eq33xDoX6YtDkYbf/WN2 drew@unremarkable-macbook-pro"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.${username} = {
    custom = {
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
