# My dotfiles including:
- .bashrc
- [Neovim](https://neovim.io/)
- [Sway](https://github.com/swaywm/sway)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [Mako](https://github.com/emersion/mako)
- [Waybar](https://github.com/Alexays/Waybar)
- [Tofi](https://github.com/philj56/tofi)
- [Satty](https://github.com/Satty-org/Satty)

# Howto Guide

**Create destination folder in your repository**
```
mkdir -p ~/Documents/<your_project_location_path>/dotfiles/<application>/.config/<application>
```

**Move your existing config files to your new location**
```
mv ~/.config/<application>/* ~/Documents/<your_project_location_path>/dotfiles/<application>/.config/<application>
```

**Remove empty location**
```
rmdir ~/.config/<application>
```

**'Stow' your dotfiles (i.e. create symlinks)**
```
stow -vt ~ <application> (under ~/Documents/Projects/dotfiles)
```

