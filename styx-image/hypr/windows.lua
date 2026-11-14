-- Window and workspace rules.
-- https://wiki.hypr.land/configuring/core/rules/

-- Ignore maximize requests from apps.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland.
hl.window_rule({
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})

-- No gaps or borders when only one tiled window, and on workspace 1.
for _, ws in ipairs({ "w[tv1]", "f[1]", "1" }) do
  hl.workspace_rule({ workspace = ws, gaps_in = 0, gaps_out = 0, border_size = 0, no_rounding = true })
end

-- Scratchpad: the bar starts btop and wiremix with these window classes
-- (quickshell Config.qml), which slide in from the special workspace.
hl.window_rule({
  match = { class = "^(btop|wiremix)$" },
  workspace = "special:magic",
  opacity = "0.8 0.8",
  animation = "slide 400 ease-in",
})

-- Steam
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })
hl.window_rule({ match = { class = "^(steam_app_306130)$" }, float = true, no_initial_focus = true })
