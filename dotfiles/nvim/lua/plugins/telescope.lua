return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { "^.git/" },
          },
          live_grep = {
            additional_args = { "--hidden" },
            file_ignore_patterns = { "^.git/" },
          },
        },
      })
      telescope.load_extension("ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Search in files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffer" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find vim help" })
      vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find marks" })
    end,
  },
}
