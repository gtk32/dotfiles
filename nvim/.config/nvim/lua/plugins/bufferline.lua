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
      vim.keymap.set('n', '<C-.>', '<Cmd>BufferLineCycleNext<CR>', { silent = true })
      vim.keymap.set('n', '<C-,>', '<Cmd>BufferLineCyclePrev<CR>', { silent = true })
    end
}
