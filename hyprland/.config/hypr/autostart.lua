-- Autostart (exec-once).
-- https://wiki.hypr.land/configuring/core/autostart/
--
-- hl.exec_cmd() spawns asynchronously: no "&" or "disown" needed.

hl.on("hyprland.start", function()
  -- Walker (launcher) and elephant (data provider service) are linked:
  -- elephant must be up before walker's UI queries it.
  hl.exec_cmd("walker --gapplication-service")
  hl.exec_cmd("systemctl --user start elephant.service")
  hl.exec_cmd(apps.waybar)
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("/usr/bin/netbird-ui")
  -- GVfs userspace virtual filesystem daemon: provides GIO mounts (trash://,
  -- network shares, MTP phones, ...) to GTK/GIO applications such as Nautilus.
  hl.exec_cmd("/usr/lib/gvfsd")
  -- Exposes those GVfs mounts over FUSE ($XDG_RUNTIME_DIR/gvfs) so that
  -- non-GIO apps can also browse them (e.g. sshfs/smb mounts in any app).
  hl.exec_cmd("/usr/lib/gvfsd-fuse $XDG_RUNTIME_DIR/gvfs -f")
end)
