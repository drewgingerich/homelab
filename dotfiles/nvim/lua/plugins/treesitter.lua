return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
        auto_install = true,
      })
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		init = function()
			vim.g.no_plugin_maps = true
		end,
		config = function()
			local ts = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "af", function()
				ts.select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				ts.select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "aa", function()
				ts.select_textobject("@parameter.outer", "textobjects")
			end)
		end,
	},
}
