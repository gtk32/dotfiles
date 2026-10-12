return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- The rewritten main branch requires Neovim 0.12+, tree-sitter-cli 0.26.1+,
  -- tar, curl, and a C compiler. It must be loaded at startup.
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")
    treesitter.setup()

    local parsers = {
      "lua", "vim", "vimdoc", "query", "caddy", "markdown", "markdown_inline",
      "bash", "yaml", "python", "json", "css", "html", "toml", "ini",
    }

    -- Reuse YAML for Ansible files and preserve the legacy INI filetype aliases.
    vim.treesitter.language.register("yaml", "yaml.ansible")
    vim.treesitter.language.register("ini", { "dosini", "confini" })

    local filetypes = {
      "lua", "vim", "help", "query", "caddy", "markdown", "bash", "yaml",
      "yaml.ansible", "python", "json", "css", "html", "toml", "ini", "dosini", "confini",
    }

    local function start_treesitter(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
        return
      end

      -- Parser installation is asynchronous; skip until its parser is available.
      local ok = pcall(vim.treesitter.start, bufnr)
      if ok then
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function(event)
        start_treesitter(event.buf)
      end,
    })

    -- Install asynchronously, then retry buffers that opened before installation finished.
    treesitter.install(parsers):await(function(err, installed)
      if err then
        vim.notify(tostring(err), vim.log.levels.ERROR, { title = "nvim-treesitter" })
      elseif not installed then
        vim.notify("One or more Tree-sitter parsers failed to install", vim.log.levels.WARN,
          { title = "nvim-treesitter" })
      end

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        start_treesitter(bufnr)
      end
    end)
  end,
}
