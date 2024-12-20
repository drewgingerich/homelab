return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			dap.adapters.godot = {
				type = "server",
				host = "127.0.0.1",
				port = 6006,
			}
			dap.configurations.gdscript = {
				{
					type = "godot",
					request = "launch",
					name = "Launch scene",
					project = "${workspaceFolder}",
					launch_scene = true,
				},
			}

			vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Debugger: toggle breakpoint" })
			vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Debugger: start/continue" })
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end

			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("dap-python").setup(
				vim.fs.joinpath(vim.fn.stdpath("data"), "mason/packages/debugpy/venv/bin/python")
			)
		end,
	},
	{
		"leoluz/nvim-dap-go",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("dap-vscode-js").setup({
				debugger_cmd = { vim.fs.joinpath(vim.fn.stdpath("data"), "mason/bin/js-debug-adapter") },
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			})

      -- local dap = require("dap")
      --
      -- if not dap.adapters["node"] then
      --   dap.adapters["node"] = function(cb, config)
      --     if config.type == "node" then
      --       config.type = "pwa-node"
      --     end
      --     local nativeAdapter = dap.adapters["pwa-node"]
      --     if type(nativeAdapter) == "function" then
      --       nativeAdapter(cb, config)
      --     else
      --       cb(nativeAdapter)
      --     end
      --   end
      -- end
		end,
	},
}
