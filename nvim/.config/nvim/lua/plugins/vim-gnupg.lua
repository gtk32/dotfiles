return {
  {
    "jamessan/vim-gnupg",
    -- De plugin laadt zichzelf zodra je een GPG-bestand opent
    ft = { "gpg", "asc", "pgp" },
    lazy = false,
    init = function()
      vim.g.GPGPreferSymmetric = 1
      vim.g.gpg_update_tty = 1
    end,
  }
}
