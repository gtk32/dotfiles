-- Keybindings.
-- https://wiki.hypr.land/configuring/core/binds/

local main_mod = "SUPER"

-- Convenience wrapper: exec a shell command via hl.dsp.exec_cmd().
local function exec(cmd)
  return hl.dsp.exec_cmd(cmd)
end

------------------
--- APPLICATIONS ---
------------------

hl.bind(main_mod .. " + Return", exec(apps.terminal), { description = "Terminal" })
hl.bind(main_mod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(main_mod .. " + E", exec("hyprshutdown"), { description = "Quit Hyprland" })
hl.bind(main_mod .. " + D", exec(apps.file_manager), { description = "File manager" })
hl.bind(main_mod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(main_mod .. " + R", exec("pkill waybar; " .. apps.waybar), { description = "Restart waybar" })
hl.bind(main_mod .. " + Space", exec(apps.menu), { description = "Launcher" })
hl.bind("ALT + Tab", exec(apps.menu .. " -m windows"), { description = "Window switcher" })
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }), { description = "Pseudo-tiling" })
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })
hl.bind(main_mod .. " + L", exec(apps.powermenu), { description = "Power menu" })
hl.bind("ALT + B", exec(apps.browser), { description = "Browser" })
hl.bind("ALT + M", exec("spotify-launcher"), { description = "Spotify" })
hl.bind("ALT + X", exec("qalculate-gtk"), { description = "Calculator" })

-- ELECTRON_OZONE_PLATFORM_HINT=wayland (set in hyprland.lua) handles the flags.
hl.bind("ALT + comma", exec("obsidian"), { description = "Obsidian" })
hl.bind("ALT + period", exec("thunderbird"), { description = "Thunderbird" })
hl.bind("ALT + F2", exec("flatpak run com.github.IsmaelMartinez.teams_for_linux"), { description = "Teams" })

-----------------
--- SCREENSHOTS ---
-----------------

hl.bind(main_mod .. " + PRINT", exec(apps.screenshot .. " -m window"), { description = "Screenshot window" })
hl.bind(main_mod .. " + SHIFT + PRINT", exec(apps.screenshot .. " -m region"), { description = "Screenshot region" })

---------------
--- FOCUS/MOVE ---
---------------

local focus_dirs = { left = "l", right = "r", up = "u", down = "d" }
for key, dir in pairs(focus_dirs) do
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = dir }), { description = "Focus " .. key })
end

hl.bind("ALT + right", hl.dsp.focus({ workspace = "+1" }), { description = "Next workspace" })
hl.bind("ALT + left", hl.dsp.focus({ workspace = "-1" }), { description = "Previous workspace" })

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

-- Cycle tabs, google-chrome only. Native check instead of shelling out to
-- hyprctl + grep.
hl.bind("SUPER + Tab", function()
  local w = hl.get_active_window()
  if w ~= nil and w.class == "google-chrome" then
    hl.dispatch(hl.dsp.send_shortcut({ window = w, mods = "CTRL", key = "TAB" }))
  end
end, { description = "Cycle tabs in google-chrome" })
