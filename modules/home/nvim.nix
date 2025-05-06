{ config, pkgs, lib, ... }:
{
  options.custom.nvim.enable = lib.mkEnableOption "Configure Neovim for this user";

  config = lib.mkIf config.custom.nvim.enable {
    home.packages = with pkgs; [
      neovim

      # Supporting tools
      fzf
      ripgrep

      # LSP & DAP servers for IDE
      astro-language-server
      gdtoolkit_4
      gopls
      harper
      helm-ls
      lua-language-server
      marksman
      nil
      prettierd
      pyright
      ruby-lsp
      ruff
      starlark-rust
      stylua
      taplo
      typescript-language-server
      vscode-langservers-extracted
      vscode-js-debug
      vue-language-server
      yaml-language-server

      # C compiler for Treesitter
      gcc
    ];

    xdg.configFile = {
      "nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/nvim";
      };
    };
  };
}
