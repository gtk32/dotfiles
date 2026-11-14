-- Keybindings (image defaults, SPEC D15). Add your own after loading this.
-- https://wiki.hypr.land/configuring/core/binds/

local main_mod = "SUPER"

local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

hl.bind(main_mod .. " + Return", exec(apps.terminal), { description = "Terminal" })
hl.bind(main_mod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(main_mod .. " + E", exec("hyprshutdown"), { description = "Quit Hyprland" })
hl.bind(main_mod .. " + D", exec(apps.file_manager), { description = "File manager" })
hl.bind(main_mod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(main_mod .. " + Space", exec("qs -p /usr/share/styx/quickshell ipc call launcher toggle"), { description = "Launcher" })
hl.bind(main_mod .. " + L", exec("qs -p /usr/share/styx/quickshell ipc call powermenu toggle"), { description = "Power menu" })
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }), { description = "Pseudo-tiling" })
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })

---------------
--- FOCUS/MOVE ---
---------------

local focus_dirs = { left = "l", right = "r", up = "u", down = "d" }
for key, dir in pairs(focus_dirs) do
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = dir }), { description = "Focus " .. key })
end

hl.bind("ALT + right", hl.dsp.focus({ workspace = "+1" }), { description = "Next workspace", dont_inhibit = true })
hl.bind("ALT + left", hl.dsp.focus({ workspace = "-1" }), { description = "Previous workspace", dont_inhibit = true })
-- hl.bind("ALT + right", hl.dsp.focus({ workspace = "+1" }), { description = "Next workspace", dont_inhibit = true })

-------------------
--- WORKSPACES 1-10 ---
-------------------

for ws = 1, 10 do
  local key = tostring(ws % 10) -- workspace 10 binds to key 0
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = tostring(ws) }), { description = "Workspace " .. ws })
  hl.bind(
    main_mod .. " + SHIFT + " .. key,
    hl.dsp.window.move({ workspace = tostring(ws) }),
    { description = "Move to workspace " .. ws }
  )
end

---------------
--- RESIZE ---
---------------

hl.bind(main_mod .. " + SHIFT + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { description = "Shrink width" })
hl.bind(main_mod .. " + SHIFT + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { description = "Grow width" })

----------------
--- SCRATCHPAD ---
----------------

hl.bind(main_mod .. " + backslash", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
hl.bind(
  main_mod .. " + SHIFT + backslash",
  hl.dsp.window.move({ workspace = "special:magic" }),
  { description = "Move to scratchpad" }
)

-----------------
--- MOUSE BINDS ---
-----------------

hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging.
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

--------------------
--- MEDIA / VOLUME ---
--------------------

hl.bind(
  main_mod .. " + F12",
  exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { repeating = true, locked = true, description = "Volume up" }
)
hl.bind(
  main_mod .. " + F11",
  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { repeating = true, locked = true, description = "Volume down" }
)
hl.bind(
  main_mod .. " + F10",
  exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { repeating = true, locked = true, description = "Toggle mute" }
)

-- Requires playerctl.
hl.bind(main_mod .. " + F9", exec("playerctl next"), { locked = true, description = "Next track" })
hl.bind(main_mod .. " + F8", exec("playerctl play-pause"), { locked = true, description = "Play/pause" })
hl.bind(main_mod .. " + F7", exec("playerctl previous"), { locked = true, description = "Previous track" })
