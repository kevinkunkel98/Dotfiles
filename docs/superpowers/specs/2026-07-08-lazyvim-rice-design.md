# LazyVim Rice Integration — Design

## Goal

Replace the current standalone "shell-ninja" Neovim config with a fresh LazyVim install, bring it under Dotfiles version control (stowed like every other app), make its background transparent to match Kitty's terminal opacity, and wire it into the existing theme switcher (`theme_select.sh`) so colorschemes follow the system-wide theme.

## Current state

- `~/.config/nvim` is a real (non-symlinked) directory containing a custom config ("shell-ninja"), using lazy.nvim as plugin manager but not the LazyVim distribution.
- `~/Documents/Dev/Dotfiles/nvim/.config/` exists but is empty — nvim is not currently stowed into the dotfiles repo.
- Kitty's terminal transparency is set via `background_opacity 0.7` in `kitty.conf`.
- Theme switching across the whole system is driven by `~/Documents/Dev/Dotfiles/hypr/.config/hypr/scripts/theme_select.sh`, which:
  1. Lets the user pick a theme name via rofi (backed by images in `~/.config/hypr/assets`).
  2. Symlinks per-app color files (`~/.config/APP/colors/${theme}.conf` → `~/.config/APP/theme.conf`, or `.css` for waybar/wlogout/swaync) via a `safe_link` helper.
  3. Signals already-running apps to reload live (`SIGUSR1` for Kitty, a D-Bus call for Ghostty).
  4. Has a `case "$theme"` block mapping theme name to VS Code / Kvantum theme names, applied via `sed`/`crudini`.
  5. Has a second `case "$theme"` block for Obsidian's `cssTheme`.
- Known theme names: `Catppuccin`, `Everforest`, `Gruvbox`, `Neon`, `TokyoNight`.

## Out of scope

- Changing the rofi theme picker UI or asset format.
- Migrating any other app's theme wiring.
- Preserving shell-ninja keymaps/config content (full backup is taken, but the replacement is a clean LazyVim install, not a merge).

## Design

### 1. Backup

Before any destructive change: `cp -r ~/.config/nvim ~/.config/nvim.bak-20260708`. This is a manual one-off step, not tracked by git, kept purely as a rollback safety net.

### 2. Install LazyVim, stowed into Dotfiles

- Clone the LazyVim starter into `~/Documents/Dev/Dotfiles/nvim/.config/nvim/` (stripping its own `.git` directory so it becomes part of the Dotfiles repo history instead).
- Restow (or re-symlink) so `~/.config/nvim` points into the dotfiles copy, matching the pattern used by `kitty/`, `waybar/`, etc.
- Add `lazy-lock.json` to `.gitignore` for this directory (standard LazyVim advice — lockfile is machine-specific/noisy) — confirm against existing `.gitignore` conventions in the repo, follow whatever the repo already does for similar lockfiles.

### 3. Transparency to match Kitty

Add `lua/config/transparent.lua`, autocmd on the `ColorScheme` event that sets `guibg=NONE` (and `ctermbg=NONE`) on the highlight groups that normally paint a solid background: `Normal`, `NormalNC`, `NormalFloat`, `SignColumn`, `LineNr`, `CursorLineNr`, `EndOfBuffer`, `Folded`, `FoldColumn`, `WinSeparator`. Because it hooks `ColorScheme` (not just `VimEnter`), it re-applies every time the colorscheme changes, including via the live theme-switch path in section 5. No plugin required — Kitty's own alpha blending provides the actual translucency; Neovim just needs to stop opaquely painting over it.

### 4. Per-theme colorscheme specs

- New directory `~/.config/nvim/colorschemes/`, one file per system theme: `Catppuccin.lua`, `Everforest.lua`, `Gruvbox.lua`, `Neon.lua`, `TokyoNight.lua`. Each is a lazy.nvim plugin spec (`priority = 1000`, sets `vim.g.lazyvim_colorscheme` and calls `vim.cmd.colorscheme(...)` in `config`).
- Mapping:
  | System theme | Nvim plugin | Variant |
  |---|---|---|
  | Catppuccin | `catppuccin/nvim` | mocha |
  | Everforest | `sainnhe/everforest` | dark |
  | Gruvbox | `ellisonleao/gruvbox.nvim` | dark |
  | TokyoNight | `folke/tokyonight.nvim` | night |
  | Neon | `folke/tokyonight.nvim` | storm (distinct variant from TokyoNight's `night`, per user decision — no dedicated "neon" nvim colorscheme exists) |
- All five plugins are added (lazy-loaded, not eager) to a LazyVim plugin spec file so they're available regardless of which one is currently active.
- `theme_select.sh` gains a `safe_link` call: `safe_link "$HOME/.config/nvim/colorschemes/${theme}.lua" "$HOME/.config/nvim/lua/plugins/colorscheme.lua"`. This makes the choice persist for the *next* nvim launch.

### 5. Live reload for already-open Neovim instances

Neovim always exposes a default IPC socket even without `--listen` (at `$XDG_RUNTIME_DIR/nvim.<pid>.0`). `theme_select.sh` gets a new block, alongside the existing Kitty/Ghostty live-reload block:

```bash
case "$theme" in
    Catppuccin) nvimColorscheme="catppuccin" ;;
    Everforest) nvimColorscheme="everforest" ;;
    Gruvbox)    nvimColorscheme="gruvbox" ;;
    TokyoNight) nvimColorscheme="tokyonight-night" ;;
    Neon)       nvimColorscheme="tokyonight-storm" ;;
    *)          nvimColorscheme="" ;;
esac

if [[ -n "$nvimColorscheme" ]]; then
    for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*.0; do
        [[ -S "$sock" ]] || continue
        nvim --server "$sock" --remote-send ":colorscheme ${nvimColorscheme}<CR>" &>/dev/null
    done
fi
```

This reuses the existing per-theme `case` pattern already established for `kvTheme`/`vscodeTheme`, so it's consistent with how the rest of the script handles unmapped/unknown themes (falls through silently, no live nvim reload attempted).

## Testing / verification

- Launch nvim standalone: confirm it renders with a transparent background over Kitty's 0.7-opacity backdrop.
- Run `theme_select.sh`, pick each of the 5 themes in turn:
  - Confirm the `lua/plugins/colorscheme.lua` symlink target updates to the right file.
  - Confirm an already-open nvim instance repaints live with the new colorscheme (no restart).
  - Quit and relaunch nvim, confirm it starts directly in the newly selected colorscheme.
- Confirm the old shell-ninja backup at `~/.config/nvim.bak-20260708` is intact and untouched throughout.
