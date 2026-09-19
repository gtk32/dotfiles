return {
  -- Blink: fast Rust-based completion engine (LSP, snippets, path, buffer).
  'saghen/blink.cmp',
  version = '*', -- use the latest prebuilt release (no build step needed)
  opts = {
    keymap = { preset = 'default' }, -- <C-space> trigger, <C-n>/<C-p> navigate, <CR> accept
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    completion = {
      documentation = { auto_show = true },
      menu = { draw = { columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } } } },
    },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.default' },
}
