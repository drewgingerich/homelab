{ ... }:
{
  flake.homeModules.nvim =
    { pkgs, ... }:
    {
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
        nixd
        nixfmt
        prettierd
        pyright
        ruby-lsp
        ruff
        rust-analyzer
        starlark-rust
        stylua
        taplo
        terraform-ls
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
          source = ../dotfiles/nvim;
          # source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/nvim";
          recursive = true;
          force = true;
        };
      };
    };
}
