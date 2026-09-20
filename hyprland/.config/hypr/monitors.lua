-- Monitor configuration.
-- https://wiki.hypr.land/configuring/core/monitors/

hl.monitor({
  output = "DP-1",
  mode = "3840x2160@160",
  position = "0x0",
  scale = 2,
})

-- Unscale XWayland.
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})
