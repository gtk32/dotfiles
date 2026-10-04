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

-- Floating keybinding cheatsheet (toggle). <leader>? instead of <leader>F1:
-- F1 collides with Vim's built-in :help binding.
vim.keymap.set('n', '<leader>?', function() require('config.cheatsheet').open() end,
  { desc = 'Keybinding cheatsheet' })

-- jj mimics <Esc> in insert and visual mode (classic Home Row escape).
-- Trade-off: a single "j" in insert mode waits ~1s before appearing
-- (timeoutlen) — type j twice when you actually want "jj" in text.
vim.keymap.set({ 'i', 'v' }, 'jj', '<Esc>', { silent = true, desc = 'Leave insert/visual mode' })
