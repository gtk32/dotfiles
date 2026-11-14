-- Desktop gaming defaults (styx SPEC D7). Conservative on purpose: every
-- setting here is documented in the Hyprland wiki. VRR and tearing depend on
-- the monitor and the game, so they stay user-side (see docs/gaming.md in
-- the styx repo for how to try them).

-- Direct scanout: lets a fullscreen game bypass compositing (less latency).
-- 2 = automatic, only for windows with content type "game".
-- https://wiki.hypr.land/configuring/core/config-options/#render
hl.config({ render = { direct_scanout = 2 } })

-- Steam games do not always announce themselves as "game" content; mark them,
-- so direct scanout (and VRR mode 3, if you enable it) apply to them.
-- https://wiki.hypr.land/configuring/core/rules/window-rules/
hl.window_rule({ match = { class = "^steam_app_\\d+$" }, content = "game" })
