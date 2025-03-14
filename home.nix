{ config, username, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  imports = [
    ./nix/user/programs/autorestic
    ./nix/user/programs/fish
    ./nix/user/programs/git
  ];

  home.packages = with pkgs; [
    asdf-vm
    bat
    devbox
    direnv
    eza
    fzf
    ffmpeg
    gnupg
    harper
    helix
    htop
    hyperfine
    imagemagick
    jq
    neovim
    pandoc
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
    prettierd
    pyright
    ruby-lsp
    ruff-lsp
    starlark-rust
    stylua
    typescript-language-server
    vscode-langservers-extracted
    vscode-js-debug
    vue-language-server
    yaml-language-server

    # C compiler for Treesitter
    gcc
  ];

  xdg.configFile = {
    "starship.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/starship/starship.toml";
    };
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/nvim";
    };
    "wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/wezterm";
    };
    "karabiner" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/karabiner";
    };
  };

  programs.home-manager.enable = true;
}
