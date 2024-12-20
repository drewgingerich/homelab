return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Search in files" })
			vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find buffer" })
			vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Find vim help" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				pickers = {
					find_files = {
						hidden = true,
						file_ignore_patterns = {
							"node_modules/.*",
							".git/.*",
              ".yarn/cache/.*",
              ".yarn/unplugged/.*",
						},
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
