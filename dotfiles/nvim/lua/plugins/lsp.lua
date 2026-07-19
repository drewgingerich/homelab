return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			vim.lsp.enable("astro")
			vim.lsp.enable("cssls")
			vim.lsp.enable("gdscript")
			vim.lsp.enable("gopls")
			vim.lsp.enable("html")
			vim.lsp.enable("jsonls")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("marksman")
			vim.lsp.enable("nixd")
			vim.lsp.enable("pyright")
			vim.lsp.enable("ruby_lsp")
			vim.lsp.enable("ruff")
			vim.lsp.enable("rust_analyzer")
			vim.lsp.enable("starlark_rust")
			vim.lsp.enable("taplo")
			vim.lsp.enable("terraform_lsp")
			vim.lsp.enable("ts_ls")
			vim.lsp.enable("volar")
			vim.lsp.enable("yamlls")

			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open LSP diagnostic float" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
			vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

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
	},
}
