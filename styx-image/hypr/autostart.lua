-- Autostart. Only what the image itself ships (SPEC D15).
hl.on("hyprland.start", function()
  -- The session shell (bar, launcher, power menu, notifications). -p pins the
  -- image copy so an old ~/.config/quickshell can not shadow it.
  hl.exec_cmd("qs -p /usr/share/styx/quickshell -d -n")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
