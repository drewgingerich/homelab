vim.g.loaded_netrw = false
vim.g.loaded_netrwPlugin = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.wo.wrap = false

vim.wo.number = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.api.nvim_create_autocmd("FileType", {
  desc = "Stop commenting new line when pressing `o` or `O` while on a commented line",
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "o" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Use tabs in GDScript files",
	pattern = "gdscript",
	callback = function()
		vim.opt_local.expandtab = false
	end,
})

