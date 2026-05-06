# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config location |
|---------|----------------|
| `fish` | `~/.config/fish/` |
| `ghostty` | `~/.config/ghostty/` |
| `nvim` | `~/.config/nvim/` |
| `lazygit` | `~/.config/lazygit/` |
| `yazi` | `~/.config/yazi/` |

## Setup

```sh
# Clone the repo
git clone <repo-url> ~/Documents/Dev/Dotfiles
cd ~/Documents/Dev/Dotfiles

# Stow everything at once
stow fish ghostty nvim lazygit yazi

# Or individually
stow nvim
```

## Notes

- `fish_variables` is intentionally excluded (machine-specific PATH/env state).
- `lazy-lock.json` is included so plugin versions are reproducible across machines.
