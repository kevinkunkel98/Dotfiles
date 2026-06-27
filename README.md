# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config location |
|---------|----------------|
| `fish` | `~/.config/fish/` |
| `ghostty` | `~/.config/ghostty/` |
| `hypr` | `~/.config/hypr/` |
| `kitty` | `~/.config/kitty/` |
| `nvim` | `~/.config/nvim/` |
| `lazygit` | `~/.config/lazygit/` |
| `rofi` | `~/.config/rofi/` |
| `swaync` | `~/.config/swaync/` |
| `waybar` | `~/.config/waybar/` |
| `wlogout` | `~/.config/wlogout/` |
| `yazi` | `~/.config/yazi/` |

## Setup

```sh
# Clone the repo
git clone <repo-url> ~/Documents/Dev/Dotfiles
cd ~/Documents/Dev/Dotfiles

# Stow everything at once
stow fish ghostty hypr kitty nvim lazygit rofi swaync waybar wlogout yazi

# Or individually
stow nvim
```

## Notes

- `fish_variables` is intentionally excluded (machine-specific PATH/env state).
- `lazy-lock.json` is included so plugin versions are reproducible across machines.
- `hypr/.config/hypr/.cache/` is intentionally excluded (runtime state: current theme/wallpaper/nightlight selection).
- `hypr/.config/hypr/Wallpapers/` is intentionally excluded (personal media, not configuration).
- `ghostty/.config/ghostty/theme.conf` and `kitty/.config/kitty/theme.conf` are relative symlinks to whichever file in `colors/` is currently active; `theme_select.sh` repoints them when you switch themes.
