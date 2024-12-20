return {
  'stevearc/oil.nvim',
  opts = {},
  config = function ()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      }
    })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
