return {
  -- Render color codes (#RRGGBB(A), rgb()/hsl() functions) with their actual
  -- color as background — highlights live while the code is being typed.
  -- NvChad fork, actively maintained (successor of the abandoned norcalli repo).
  'NvChad/nvim-colorizer.lua',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    filetypes = { '*' }, -- attach to every buffer
    user_default_options = {
      RGB = true, -- #RGB
      RRGGBB = true, -- #RRGGBB
      RRGGBBAA = true, -- #RRGGBBAA (alpha included)
      css = true, -- rgb()/rgba()/hsl() syntax
      css_fn = true, -- any css color function
      names = false, -- css color names (off: too noisy in code)
      mode = 'background', -- 'background' | 'foreground' | 'virtualtext'
    },
  },
}