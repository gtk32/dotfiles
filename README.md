# dotfiles

GNU [stow](https://www.gnu.org/software/stow/)-managed dotfiles for Arch Linux (also compatible with Fedora/macOS).

Includes: bash, hyprland, kitty, mako, nvim, quickshell, satty, starship, sway, tofi, waybar.

## Layout

Every application is a separate **stow package** containing its own `.config/` tree:

```
dotfiles/
├── nvim/.config/nvim/
├── kitty/.config/kitty/
└── waybar/.config/waybar/
```

## Add a new config to the dotfiles

```bash
cd ~/dotfiles                                        # repo root

# 1. create the package directory (match the real path under .config)
mkdir -p <app>/.config/<app>

# 2. move your existing config into it
mv ~/.config/<app>/* <app>/.config/<app>/

# 3. stow it (creates symlinks in ~)
stow -t ~ <app>
```

If the original directory still exists in `$HOME`, stow will refuse — remove the empty leftover first:

```bash
rmdir ~/.config/<app>
```

## Roll out all configs on a clean machine

```bash
git clone https://github.com/gtk32/dotfiles.git
cd dotfiles

stow -t ~ */        # stow every package at once
```

> Stow never overwrites existing files. If a target already exists in `$HOME`, either remove it first or use `stow --adopt -t ~ */` to absorb the existing files into the repo.

## Roll out a single config

Stow works per package, so deploying just one application is trivial:

```bash
stow -t ~ nvim      # only neovim
stow -t ~ kitty     # only kitty
```

To undo (remove the symlinks again):

```bash
stow -D -t ~ nvim   # unstow
stow -R -t ~ nvim   # or restow in one step
```

## Quickshell: extra setup after stowing

The quickshell package (bar, launcher, power menu, notifications) needs two things that are deliberately **not** in this repo:

1. **Weather location** in `weather.json` (git-ignored). Copy the example and fill in your coordinates:

   ```bash
   cp ~/.config/quickshell/weather.example.json ~/.config/quickshell/weather.json
   # edit lat/lon; leave "apiKey" empty when using the keyring (step 2)
   ```

2. **OpenWeatherMap API key** in the keyring (needs `gnome-keyring` running and unlocked at login):

   ```bash
   secret-tool store --label="OpenWeatherMap" service openweathermap
   ```

   Quickshell reads it at startup with `secret-tool lookup service openweathermap`. As a fallback, an `"apiKey"` in `weather.json` also works.

Start it with `qs -d` (e.g. from the Hyprland autostart). Launcher and power menu are toggled via `qs ipc call launcher toggle` and `qs ipc call powermenu toggle`.
