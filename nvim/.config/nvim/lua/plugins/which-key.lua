return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function(_, opts)
    -- Start WhichKey met de standaard opties
    local wk = require("which-key")
    wk.setup(opts)

    -- Hier registreren we je custom labels/beschrijvingen
    wk.add({
      { "<C-q>", desc = "Close current buffer", mode = "n" },
      { "<C-Tab>", desc = "Next buffer", mode = "n" },
      { "<leader>cd", "<Cmd>Oil<CR>", desc = "Open Oil file manager" },
    })
  end,
}
