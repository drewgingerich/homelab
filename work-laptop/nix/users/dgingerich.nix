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
      karabiner.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    programs.obsidian.enable = true;

    programs.qutebrowser = {
      enable = true;
      searchEngines = {
        udm14 = "https://www.google.com/search?udm=14&q={}";
        kagi = "https://kagi.com/search?q={}";
        ddg = "https://duckduckgo.com/?q={}";
      };
    };

    home.packages = with pkgs; [
      asdf-vm
      awscli2
      aws-vault
      bitwarden-desktop
      claude-code
      colima
      crush
      devbox
      docker-buildx
      docker-client
      docker-compose
      granted
      k9s
      kubectl
      opencode
      pipx
      python313
      raycast
      rectangle
      uv
      wv
      wezterm
      zotero
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
