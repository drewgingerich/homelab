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

vim.keymap.set("v", "<leader>y", '"*y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>p", '"*p', { desc = "Paste selection from system clipboard before cursor" })
vim.keymap.set("n", "<leader>P", '"*P', { desc = "Paste selection from system clipboard after cursor" })

vim.keymap.set("n", "U", "<C-r>", { desc = "Redo change" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center cursor vertically" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center cursor vertically" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Go to next match and center cursor vertically" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Go to previous match and center cursor vertically" })

vim.keymap.set("x", "p", '"_dP', { desc = "Paste over selection without saving to register" })

vim.keymap.set("n", "<leader>s", ":%s//", { desc = "Replace search matches" })
