return {
  -- Installs language servers (downloaded & stored in stdpath('data')/mason,
  -- cross-platform: works on Linux and macOS; npm-based servers need node >= 18).
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  -- Bridge between Mason and lspconfig (installs the servers listed here).
  {
    'mason-org/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'ansiblels',
          'lua_ls',
          'bashls',
        },
      }
    end,
  },
  -- Core LSP configuration (native API, Neovim >= 0.11).
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- lua_ls: recognise Neovim's global `vim`
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      })

      -- Enable the LSP servers (mason-lspconfig v2 no longer does this).
      vim.lsp.enable({ 'ansiblels', 'bashls', 'lua_ls' })

      -- Diagnostic keymaps (global)
      -- Note: `K` is left untouched so it keeps its native LSP hover binding.
      vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end,
        { desc = 'Previous diagnostic' })
      vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end,
        { desc = 'Next diagnostic' })
      vim.keymap.set('n', '<leader>k', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

      -- Customize diagnostic signs
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
          },
        },
      })
    end,
  },
  -- Linter for Ansible.
  {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = {
        ['yaml.ansible'] = { 'ansible_lint' },
      }
      -- Automatically run linter on save.
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint("ansible_lint")
        end,
      })
    end
  },
}
