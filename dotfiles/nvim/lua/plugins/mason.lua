return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"stylua",

				"pyright",
				"ruff-lsp",
				"black",
				"debugpy",

				"astro",

				"gopls",
				"delve",

				"prettier",

				"json-lsp",
				"yaml-language-server",

				"typescript-language-server",
				"js-debug-adapter",

				"ruby-lsp",

				"marksman",
			},
		},
		config = function()
			require("mason").setup()
		end,
	},
}
