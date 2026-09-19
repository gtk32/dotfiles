return {
  "nvim-treesitter/nvim-treesitter",
  -- `master` branch: compatible with Neovim 0.11.
  -- The `main` branch rewrite requires Neovim 0.12 — migrate when all
  -- machines (Arch desktop, Fedora, macOS) run >= 0.12.
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc", "query", "caddy", "markdown", "markdown_inline",
        "bash", "yaml", "python", "json", "css", "html",
        "toml", "ini",
      },

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      indent = { enable = true },
    })

    -- Use the (maintained) yaml grammar for Ansible files: the dedicated
    -- `ansible` parser was removed from the registry and its source repo
    -- (tree-sitter-grammars/tree-sitter-ansible) no longer exists.
    -- Ansible-specific feedback still comes from ansiblels (LSP) + ansible-lint.
    vim.treesitter.language.register("yaml", "yaml.ansible")
  end,
}
