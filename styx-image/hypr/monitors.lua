-- Any monitor at its preferred mode, placed automatically at scale 1.
-- Override in your own config, e.g.
--   hl.monitor({ output = "DP-1", mode = "3840x2160@144", position = "0x0", scale = 2 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Unscale XWayland.
hl.config({ xwayland = { force_zero_scaling = true } })
