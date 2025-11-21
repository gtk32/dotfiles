-- KEY BINDINGS
vim.g.mapleader = " "

-- Ctrl + c for exiting insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Navigate splits
vim.keymap.set('n', '<C-PageUp>', '<C-w>k', { desc = 'Move to split above' })
vim.keymap.set('n', '<C-PageDown>', '<C-w>j', { desc = 'Move to split below' })
