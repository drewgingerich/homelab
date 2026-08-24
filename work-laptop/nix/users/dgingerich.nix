{ pkgs, ... }:
let
  username = "dgingerich";
in
{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  system.primaryUser = username;

  home-manager.users.${username} = {
    custom = {
      cliTools.enable = true;
      fish.enable = true;
      git = {
        enable = true;
        userEmail = "drew.gingerich@ithaka.org";
      };
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    # programs.qutebrowser = {
    #   enable = true;
    #   searchEngines = {
    #     udm14 = "https://www.google.com/search?udm=14&q={}";
    #     kagi = "https://kagi.com/search?q={}";
    #     ddg = "https://duckduckgo.com/?q={}";
    #   };
    # };

    home.packages = with pkgs; [
      awscli2
      aws-vault
      # bitwarden-desktop
      devbox
      docker-buildx
      docker-client
      docker-compose
      k9s
      kubectl
      rectangle
      uv
      wv
      wezterm
      zotero
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}
