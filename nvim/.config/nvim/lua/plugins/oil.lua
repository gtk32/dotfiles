return {
  {
    'stevearc/oil.nvim',
    -- opts = {},
    dependencies = {
      { "nvim-tree/nvim-web-devicons", opts = {} }
    },
    lazy = false,
    config = function()
      require("oil").setup({
        keymaps = {
          ["<BS>"] = { "actions.parent", mode = "n" },
          ["q"] = "actions.close",
        },
      })
      -- Keybinds
      vim.keymap.set("n", "<leader>cd", vim.cmd.Oil)
    end,
  },
}
