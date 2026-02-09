return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- Use the latest (main branch)
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local configs = require("nvim-treesitter")

    configs.setup({
      ensure_installed = { 
        "lua", "vim", "caddy", "query", "markdown", "markdown_inline",
        "bash", "yaml", "ansible", "python", "json", "css", "html", 
        "toml", "ini"
      },
      
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      
      indent = { enable = true },
    })
    
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
