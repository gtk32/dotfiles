# dotfiles

GNU [stow](https://www.gnu.org/software/stow/)-managed dotfiles for Arch Linux (also compatible with Fedora/macOS).

Includes: bash, hyprland, kitty, mako, nvim, satty, starship, sway, tofi, waybar.

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
