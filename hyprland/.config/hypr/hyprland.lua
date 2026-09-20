-- Hyprland configuration (Lua). Requires Hyprland >= 0.53.
-- https://wiki.hypr.land/configuring/
--
-- Entry point: defines shared variables, environment variables and input.
-- The rest lives in modules, required at the bottom of this file.
-- Each require() is a separate scope, so an error in one module does not
-- stop the rest of the config from loading.

-------------------
--- MY PROGRAMS ---
-------------------

-- Shared with autostart.lua and bindings.lua via a global, because
-- require() scopes are isolated (locals here would not be visible there).
apps = {
  terminal     = "kitty",
  file_manager = "nautilus --new-window",
  menu         = "walker",
  browser      = "flatpak run app.zen_browser.zen",
  powermenu    = (os.getenv("HOME") or "") .. "/.local/bin/powermenu.sh",
  screenshot   = (os.getenv("HOME") or "") .. "/.local/bin/hyprshot",
  waybar       = "waybar --config $HOME/.config/waybar/config-hyprland.jsonc",
}

-------------------------------
--- ENVIRONMENT VARIABLES ---
-------------------------------

-- https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Capitaine Cursors - White")

-- Force Electron apps onto Wayland (Obsidian, Teams, ...).
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- Toolkit-specific scale for the 4K monitor.
hl.env("GDK_SCALE", "2")

-----------
--- INPUT ---
-----------

-- https://wiki.hypr.land/configuring/core/config-options/#input
hl.config({
  input = {
    kb_layout = "us,us",
    kb_variant = ",intl",
    kb_model = "",
    kb_options = "grp:alt_shift_toggle",
    kb_rules = "",

    repeat_rate = 35,
    repeat_delay = 200,

    follow_mouse = 1,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = false,
    },
  },
})

-- 1:1 trackpad gestures.
-- https://wiki.hypr.land/configuring/core/binds/gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

--------------
--- MODULES ---
--------------

require("./monitors")
require("./autostart")
require("./looknfeel")
require("./bindings")
require("./windows")
