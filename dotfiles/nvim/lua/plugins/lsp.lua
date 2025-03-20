return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.gleam.setup({ capabilities = capabilities })
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.ts_ls.setup({ capabilities = capabilities })
			lspconfig.jsonls.setup({ capabilities = capabilities })
			lspconfig.gopls.setup({ capabilities = capabilities })
			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.astro.setup({ capabilities = capabilities })
			lspconfig.ruby_lsp.setup({ capabilities = capabilities })
			lspconfig.marksman.setup({ capabilities = capabilities })
			lspconfig.ruff.setup({ capabilities = capabilities })
			lspconfig.yamlls.setup({ capabilities = capabilities })
      lspconfig.harper_ls.setup({ capabilities = capabilities })
			lspconfig.helm_ls.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
			lspconfig.nil_ls.setup({ capabilities = capabilities })
			lspconfig.gdscript.setup({
				name = "godot",
				cmd = vim.lsp.rpc.connect("127.0.0.1", "6005"),
			})
			lspconfig.volar.setup({ capabilities = capabilities })
			-- lspconfig.vale_ls.setup({ capabilities = capabilities })
			lspconfig.starlark_rust.setup({
				capabilities = capabilities,
				filetypes = { "star", "bzl", "BUILD.bazel", "Tiltfile" },
			})

			vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Open LSP diagnostic float" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
			vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

			local telescope = require("telescope.builtin")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					vim.keymap.set(
						"n",
						"gD",
						vim.lsp.buf.declaration,
						{ buffer = ev.buf, desc = "Go to type declaration" }
					)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
					vim.keymap.set("n", "gr", telescope.lsp_references, { buffer = ev.buf, desc = "Find references" })
					vim.keymap.set(
						"n",
						"gi",
						telescope.lsp_implementations,
						{ buffer = ev.buf, desc = "Find implementations" }
					)
					vim.keymap.set(
						"n",
						"<leader>k",
						vim.lsp.buf.hover,
						{ buffer = ev.buf, desc = "Show LSP information" }
					)
					vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
					vim.keymap.set(
						"n",
						"<C-k>",
						vim.lsp.buf.signature_help,
						{ buffer = ev.buf, desc = "Show signature help" }
					)
					vim.keymap.set(
						"n",
						"<leader>D",
						vim.lsp.buf.type_definition,
						{ buffer = ev.buf, desc = "Show type definition" }
					)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
					vim.keymap.set("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, { buffer = ev.buf, desc = "Format file" })
				end,
			})
		end,
		dependencies = { "nvim-telescope/telescope.nvim", "towolf/vim-helm" },
	},
	{
		"towolf/vim-helm",
    -- 24-12-12
    -- Needed to prevent yamlls from attaching to helm filetype
    -- This is because Helm uses the `.yaml` file extension even though it's not a YAML file
    -- https://github.com/neovim/nvim-lspconfig/issues/2252#issuecomment-2198825338
		ft = "helm",
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}
