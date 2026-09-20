-- Window and workspace rules.
-- https://wiki.hypr.land/configuring/core/rules/

-- Ignore maximize requests from apps.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland.
hl.window_rule({
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})

--------------------------
--- SMART GAPS / BORDERS ---
--------------------------

-- No gaps or borders when only one tiled window, and on workspace 1.
-- https://wiki.hypr.land/configuring/core/rules/workspace-rules/
for _, ws in ipairs({ "w[tv1]", "f[1]", "1" }) do
  hl.workspace_rule({ workspace = ws, gaps_in = 0, gaps_out = 0, border_size = 0, no_rounding = true })
end

--------------
--- SCRATCHPAD ---
--------------

hl.window_rule({
  match = { class = "^(btop|calcure|pulsemixer|wifi)$" },
  workspace = "special:magic",
  opacity = "0.8 0.8",
  animation = "slide 400 ease-in",
})

-----------
--- STEAM ---
-----------

hl.window_rule({ match = { class = "steam" }, float = true })
hl.window_rule({ match = { class = "steam", title = "Steam" }, center = true, size = { 1100, 700 } })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })
hl.window_rule({ match = { class = "steam" }, idle_inhibit = "fullscreen" })

---------------
--- QALCULATE ---
---------------

hl.window_rule({ match = { class = "qalculate-gtk" }, float = true, center = true, size = { 700, 600 } })
