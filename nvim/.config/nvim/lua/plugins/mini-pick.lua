return {
  'nvim-mini/mini.pick',
  version = false,
  config = function()
    local minipick = require("mini.pick")
    minipick.setup({})

    -- Keymaps
    vim.keymap.set("n", "<leader>ff", minipick.builtin.files, { desc = "Find Files" })
    vim.keymap.set("n", "<leader>fb", minipick.builtin.buffers, { desc = "Find Buffers" })
    vim.keymap.set("n", "<leader>fg", minipick.builtin.grep_live, { desc = "Find keywords in files" })
    vim.keymap.set("n", "<leader>fh", minipick.builtin.help, { desc = "Search in documentation" })
  end,
}
