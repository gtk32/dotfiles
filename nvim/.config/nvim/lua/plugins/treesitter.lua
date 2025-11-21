return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  build = ":TSUpdate",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "yaml.ansible" },
      },
      indent = { enable = true },
      autotag = { enable = true },
      ensure_installed = {
        "bash",
        "caddy",
        "css",
        "diff",
        "dockerfile",
        "html",
        "ini",
        "jinja",
        "jq",
        "json",
        "lua",
        "regex",
        "ssh_config",
        "sway",
        "terraform",
        "toml",
        "vim",
        "vimdoc",
      }
    })
  end
}
