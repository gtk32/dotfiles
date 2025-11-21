return {
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("moonfly")  -- safe: runs after plugin is loaded
    end,
  },
  {
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  lazy = true, -- disable this theme in Lazy
  config = function()
    require('onedark').setup {
      style = 'darker'
    }
    require('onedark').load()
  end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { theme = 'moonfly' } -- change here your lualine theme
  },
}
