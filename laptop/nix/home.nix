{ config, username, pkgs, ... }:
{
  home.username = username;
  home.homeDirectory = /Users/${username};
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    asdf
    autorestic
    bat
    delta
    devbox
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
    restic
    ripgrep
    starship
    tealdeer
    wget
    yq
    zoxide

    # LSP & DAP servers for IDE
    astro-language-server
    gdtoolkit_4
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
    vscode-js-debug
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
    "fish" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/fish";
    };
  };

  programs.home-manager.enable = true;
}
