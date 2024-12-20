return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local helpers = require("null-ls.helpers")

    -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/HELPERS.md
    local gdformat_source = {
      method = { null_ls.methods.FORMATTING, null_ls.methods.RANGE_FORMATTING },
      filetypes = { "gd", "gdscript", "gdscript3" },
      generator = helpers.formatter_factory({
        command = vim.fs.joinpath(vim.fn.stdpath("data"), "mason/bin/gdformat"),
        args = { "$FILENAME" },
        to_temp_file = true,
        from_temp_file = true,
        use_cache = true,
      }),
    }

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        gdformat_source,
      },
    })
  end,
}
