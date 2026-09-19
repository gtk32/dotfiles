-- KEY BINDINGS
vim.g.mapleader = " "

-- Ctrl + c for exiting insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Navigate splits
vim.keymap.set('n', '<C-PageUp>', '<C-w>k', { desc = 'Move to split above' })
vim.keymap.set('n', '<C-PageDown>', '<C-w>j', { desc = 'Move to split below' })

-- Delete/change to end of line without yanking into the default register
vim.keymap.set('n', 'D', '"_D', { silent = true, desc = 'Delete to EOL (no yank)' })
vim.keymap.set('n', 'C', '"_C', { silent = true, desc = 'Change to EOL (no yank)' })
