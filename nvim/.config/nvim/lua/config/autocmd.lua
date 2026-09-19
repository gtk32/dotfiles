-- Smart Ansible YAML detection: only mark a YAML file as Ansible when it
-- contains Ansible markers or lives in a typical Ansible path (roles/, tasks/,
-- handlers/, etc.). Regular YAML (compose, CI, k8s) stays plain yaml.
-- NOTE: this entry replaces the builtin yml/yaml detection, so the fallback
-- must be an explicit 'yaml' (returning nil would leave the filetype unset).
local function detect_ansible(path, bufnr)
  -- Path-based detection (playbooks, roles, molecule, etc.)
  if path then
    local p = path:lower()
    if p:match('/roles/') or p:match('/playbooks/') or p:match('/tasks/')
      or p:match('/handlers/') or p:match('/defaults/') or p:match('/molecule/')
      or p:match('/site%.yml') or p:match('/site%.yaml') then
      return 'yaml.ansible'
    end
  end

  -- Content-based detection (scan the first 80 lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 80, false)
  for _, line in ipairs(lines) do
    if line:match('^%s*%-?%s*hosts:') or line:match('^%s*tasks:')
      or line:match('^%s*become:') or line:match('^%s*import_playbook:')
      or line:match('^%s*roles:') or line:match('^%s*ansible_builtin') then
      return 'yaml.ansible'
    end
  end
  return 'yaml' -- fall back to plain yaml
end

vim.filetype.add({
  extension = {
    yml = detect_ansible,
    yaml = detect_ansible,
  },
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


