# Run stow for kitty in dry-run mode
stow -n -v --target="$HOME" kitty

# Run stow for kitty
stow -v --target="$HOME" kitty

# Met deze optie hoef je de originele file / folder niet de backuppen / verwijderen
stow -v --target="$HOME" --adopt kitty
