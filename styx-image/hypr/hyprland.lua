-- styx: default Hyprland configuration, shipped in the image at
-- /usr/share/styx/hypr/hyprland.lua (SPEC D15). Generic on purpose: no
-- monitor, no personal apps. A user config loads it and overrides after it:
--
--   -- ~/.config/hypr/hyprland.lua
--   pcall(require, "/usr/share/styx/hypr/hyprland")
--   -- ... own settings, later calls win ...
--
-- Hyprland >= 0.55 (Lua). Each require() is its own scope, so an error in
-- one module does not stop the others.

-- Shared with autostart.lua and bindings.lua through a global, because
-- require() scopes are isolated.
apps = {
  terminal     = "kitty",
}

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Force Electron apps onto Wayland.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

hl.config({
  input = {
    kb_layout = "us",
    repeat_rate = 35,
    repeat_delay = 200,
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = { natural_scroll = false },
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Relative require paths resolve from the *user's* main config, not from this
-- file, so the modules are loaded by absolute path.
local dir = "/usr/share/styx/hypr/"
for _, module in ipairs({ "monitors", "autostart", "looknfeel", "bindings", "windows", "gaming" }) do
  require(dir .. module)
end
