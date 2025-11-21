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
