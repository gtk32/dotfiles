# styx-image

Files consumed by the [styx](https://github.com/gtk32/styx) image build. They
are **not** stow packages: `stow */` would link them into `$HOME`, so stow the
packages by name (or `stow -t ~ $(ls -d */ | grep -v '^styx-image/')`).

- `hypr/`: the generic Hyprland defaults the image installs to
  `/usr/share/styx/hypr`. A user config loads them with
  `pcall(require, "/usr/share/styx/hypr/hyprland")` and overrides afterwards.
- The shell itself is `quickshell/.config/quickshell` (without `greeter/`,
  which the image keeps in its own repo because it needs image-specific paths).
- Personal shell settings: `styx/.config/styx/shell.json` (see `Config.qml`);
  the weather key and location live in `~/.config/styx/weather.json`
  (move it from `~/.config/quickshell/weather.json`).
