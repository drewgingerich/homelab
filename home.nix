{ config, username, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    asdf-vm
    autorestic
    bat
    delta
    devbox
    direnv
    eza
    fzf
    ffmpeg
    git
    git-lfs
    gh
    glab
    gnupg
    harper
    helix
    htop
    hyperfine
    imagemagick
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
    "fish" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/fish";
    };
    "autorestic" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/autorestic";
    };
    "karabiner" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/karabiner";
    };
  };
  home.file = {
    ".gitconfig" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/git/.gitconfig";
    };
  };

  launchd = {
    agents = {
      autorestic = {
        enable = true;
        config = {
            ProgramArguments = [
              "${pkgs.autorestic}/bin/autorestic"
              "backup" "--all" "--ci"
              "--restic-bin" "${pkgs.restic}/bin/restic"
            ];
            StartCalendarInterval = [{
              Hour = 5;
              Minute = 0;
            }];
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stderr.log";
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stdout.log";
        };
      };
    };
  };

  programs.home-manager.enable = true;
}
