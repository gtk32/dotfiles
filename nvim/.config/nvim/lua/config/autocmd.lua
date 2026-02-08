-- Force filetype for all YAML files to be Ansible
-- This creates a dedicated group to ensure this rule is not overridden.
local ansible_ft_group = vim.api.nvim_create_augroup('AnsibleFiletype', { clear = true })
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = ansible_ft_group,
  pattern = { '*.yaml', '*.yml' },
  command = 'set filetype=yaml.ansible',
})

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- Create an autocommand group for custom deletions
vim.api.nvim_create_augroup("CustomDeleteWithoutYank", { clear = true })

-- Map Shift+D (D) and Shift+C (C) in normal mode to delete to black hole register
vim.api.nvim_create_autocmd("BufEnter", {
    group = "CustomDeleteWithoutYank",
    callback = function()
        -- 'D' deletes to end of line, 'C' deletes to end of line and enters insert
        vim.keymap.set('n', 'D', '"_D', { noremap = true, silent = true })
        vim.keymap.set('n', 'C', '"_C', { noremap = true, silent = true })
    end
})
