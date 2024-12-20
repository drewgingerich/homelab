{ config, username, pkgs, ... }:
{
  home.username = "drew";
  home.homeDirectory = /Users/drew;
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    bat
    delta
    direnv
    eza
    fzf
    ffmpeg
    git
    gh
    glab
    helix
    htop
    hyperfine
    jq
    lazygit
    neovim
    pandoc
    ripgrep
    starship
    tealdeer
    wget
    yq
    zoxide

    # Language servers for IDE
    astro-language-server
    gopls
    helm-ls
    lua-language-server
    marksman
    nil
    nodePackages.vscode-json-languageserver
    pyright
    ruby-lsp
    ruff-lsp
    starlark-rust
    typescript-language-server
    vale-ls
    vue-language-server
    yaml-language-server
  ];

  xdg.configFile = {
    "starship.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/starship/starship.toml";
    };
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/nvim";
    };
    "wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/wezterm";
    };
  };

  programs.home-manager.enable = true;
}
