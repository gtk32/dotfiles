return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup{
        options = {
          -- indicator style: "underline", "none", or a custom string
          indicator = {
            icon = '▎',
            style = 'icon',
          },
        },
      }
      -- Keybinds
      vim.keymap.set('n', '\x1b[9;5u', '<C-Tab>', { remap = true }) -- Hack for Kitty
      vim.keymap.set('n', '<C-Tab>', '<Cmd>BufferLineCycleNext<CR>', { silent = true })
      vim.keymap.set('n', '<C-q>', '<Cmd>bdelete<CR>', { silent = true })
    end
}
