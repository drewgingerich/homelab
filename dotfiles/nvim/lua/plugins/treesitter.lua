return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"RRethy/nvim-treesitter-textsubjects",
		},
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "dockerfile" },
				},
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>ss",
						node_incremental = "<leader>si",
						scope_incremental = "<leader>sc",
						node_decremental = "<leader>sd",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = { query = "@function.outer", desc = "function" },
							["if"] = { query = "@function.inner", desc = "function body" },
							["aa"] = { query = "@parameter.outer", desc = "function argument" },
						},
						include_surrounding_whitespace = true,
					},
				},
				textsubjects = {
					enable = true,
					prev_selection = ",",
					keymaps = {
						["."] = { "textsubjects-smart", desc = "smart selection" },
						[";"] = { "textsubjects-container-outer", desc = "container" },
						["i;"] = { "textsubjects-container-inner", desc = "inside container" },
					},
				},
			})
		end,
	},
}

-- Resources
-- https://www.youtube.com/watch?v=ff0GYrK3nT0
