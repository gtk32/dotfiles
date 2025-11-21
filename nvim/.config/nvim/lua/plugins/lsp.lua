return {
  -- Ensures linters and language servers are installed.
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'ansiblels',
        'bashls',
        'lua_ls',
      },
    },
  },
  -- Core LSP configuration.
  {
    'neovim/nvim-lspconfig',
  },
  -- Bridge between Mason and lspconfig.
  {
    'williamboman/mason-lspconfig.nvim',
    -- enabled = false,
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'ansiblels',
          'lua_ls',
          'bashls',
        },
      }

      -- 🔹 Diagnostic keymaps (global)
      vim.keymap.set("n", "K", vim.diagnostic.open_float, { desc = "Show diagnostic message" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>k", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })

      -- 🔹 Customize diagnostic signs
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
          },
        },
      })
    end,
  },
  -- Linter for Ansible.
  {
    'mfussenegger/nvim-lint',
    -- enabled = false,
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
