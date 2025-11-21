# Run stow for kitty in dry-run mode
```
stow -n -v --target="$HOME" kitty
```

# Run stow for kitty
```
stow -v --target="$HOME" kitty
```

# With this option, you don't need to remove the original file. It will overwrite
```
stow -v --target="$HOME" --adopt kitty
```

# "Unstow" / Remove symlinks. This will remove the ~/.config/satty/config.toml (because it is symlinked)
```
stow -v -D --target="$HOME" satty
```
