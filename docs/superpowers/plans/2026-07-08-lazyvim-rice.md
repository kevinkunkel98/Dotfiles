# LazyVim Rice Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the standalone "shell-ninja" Neovim config with a LazyVim install that lives in the Dotfiles repo, renders transparent to match Kitty's opacity, and switches colorscheme in lockstep with the system-wide theme switcher.

**Architecture:** LazyVim starter is vendored into `Dotfiles/nvim/.config/nvim/` and the live `~/.config/nvim` becomes a plain symlink to it (same pattern already used for `~/.config/waybar`). A `ColorScheme` autocmd strips background highlights so Kitty's alpha shows through. Five small lazy.nvim plugin-spec files (one per system theme) live under `colorschemes/`; `theme_select.sh` symlinks whichever one matches the chosen theme onto `lua/plugins/colorscheme.lua` (mirrors its existing `safe_link` pattern for Kitty/Ghostty/waybar) and additionally pushes a live `:colorscheme` command into any already-running Neovim's default RPC socket.

**Tech Stack:** Neovim + LazyVim (lazy.nvim), Lua, Bash (`theme_select.sh`), git.

## Global Constraints

- No GNU `stow` binary is installed on this machine (verified: `which stow` → not found), even though `.stowrc` exists. Every other "stowed" app in this repo that is *actually* live-symlinked (e.g. waybar) was symlinked manually with `ln -sfn`. Do the same for nvim — do not attempt to invoke `stow`.
- Repo root: `/home/kevin/Documents/Dev/Dotfiles`. Live config root: `/home/kevin/.config`.
- Currently active system theme is `Gruvbox` (from `~/.config/hypr/.cache/.theme`) — the default/initial colorscheme symlink must point at `Gruvbox.lua` to match.
- `theme_select.sh` lives at `/home/kevin/Documents/Dev/Dotfiles/hypr/.config/hypr/scripts/theme_select.sh` and is itself a live-symlinked file reachable at that same path (edit it directly in the repo).
- Known system theme names, exact casing: `Catppuccin`, `Everforest`, `Gruvbox`, `Neon`, `TokyoNight`.
- LazyVim convention: commit `lazy-lock.json` (do **not** gitignore it) — it pins plugin commits for reproducibility.

---

### Task 1: Backup current config

**Files:**
- Create: `~/.config/nvim.bak-20260708/` (full copy, outside git, not part of this repo)

- [ ] **Step 1: Copy current config out of the way**

```bash
cp -r ~/.config/nvim ~/.config/nvim.bak-20260708
```

- [ ] **Step 2: Verify the backup is complete**

```bash
diff -rq ~/.config/nvim ~/.config/nvim.bak-20260708
```

Expected: no output (directories identical).

---

### Task 2: Vendor LazyVim starter into the Dotfiles repo and go live

**Files:**
- Create: `Dotfiles/nvim/.config/nvim/` (entire LazyVim starter tree: `init.lua`, `lua/config/{autocmds,keymaps,lazy,options}.lua`, `lua/plugins/example.lua`, `.neoconf.json`, `stylua.toml`, `.gitignore`)
- Modify: `Dotfiles/.gitignore` (none needed — LazyVim's own `.gitignore` inside the vendored tree handles `lazy-lock.json`'s sibling noise; `lazy-lock.json` itself stays tracked)

**Interfaces:**
- Produces: live path `~/.config/nvim` resolving (via symlink) to `Dotfiles/nvim/.config/nvim`, which Task 3 and Task 4 both add files under.

- [ ] **Step 1: Remove the old real directory (already backed up in Task 1)**

```bash
rm -rf ~/.config/nvim
```

- [ ] **Step 2: Clone the LazyVim starter directly into the repo path**

```bash
mkdir -p ~/Documents/Dev/Dotfiles/nvim/.config
git clone https://github.com/LazyVim/starter.git ~/Documents/Dev/Dotfiles/nvim/.config/nvim
rm -rf ~/Documents/Dev/Dotfiles/nvim/.config/nvim/.git
```

- [ ] **Step 3: Symlink the live config to the repo copy**

```bash
ln -sfn ~/Documents/Dev/Dotfiles/nvim/.config/nvim ~/.config/nvim
```

- [ ] **Step 4: Verify the symlink and that LazyVim bootstraps cleanly**

```bash
readlink -f ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

Expected: `readlink -f` prints `/home/kevin/Documents/Dev/Dotfiles/nvim/.config/nvim`; the `Lazy! sync` run exits 0 after installing `lazy.nvim` and the default LazyVim plugin set (may take a minute on first run, prints plugin install progress, no `Error` lines).

- [ ] **Step 5: Commit**

```bash
cd ~/Documents/Dev/Dotfiles
git add nvim/
git commit -m "feat: vendor LazyVim starter, replace shell-ninja nvim config"
```

---

### Task 3: Transparent background to match Kitty's opacity

**Files:**
- Create: `Dotfiles/nvim/.config/nvim/lua/config/transparent.lua`
- Modify: `Dotfiles/nvim/.config/nvim/init.lua`

**Interfaces:**
- Consumes: nothing from earlier tasks beyond the LazyVim tree existing.
- Produces: `require("config.transparent")` call in `init.lua`, executed on every Neovim start and re-applied on every `ColorScheme` event — Task 4's per-theme files trigger `:colorscheme`, which re-fires this autocmd.

- [ ] **Step 1: Write the transparency module**

```lua
-- lua/config/transparent.lua
local groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
  "Folded",
  "FoldColumn",
  "WinSeparator",
}

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
  callback = function()
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
  end,
})
```

- [ ] **Step 2: Load it from init.lua**

Current `init.lua` reads:

```lua
require("config.lazy")
```

Change to:

```lua
require("config.lazy")
require("config.transparent")
```

- [ ] **Step 3: Verify highlight groups end up background-less**

```bash
nvim --headless -c "redir! > /tmp/hi-check.txt" -c "hi Normal" -c "hi SignColumn" -c "redir END" -c "qa"
cat /tmp/hi-check.txt
```

Expected: both lines show no `guibg=`/`ctermbg=` component (e.g. `Normal xxx guifg=#c0caf5`), confirming background is unset.

- [ ] **Step 4: Commit**

```bash
cd ~/Documents/Dev/Dotfiles
git add nvim/.config/nvim/lua/config/transparent.lua nvim/.config/nvim/init.lua
git commit -m "feat: strip nvim background highlights to match kitty opacity"
```

---

### Task 4: Per-theme colorscheme specs

**Files:**
- Create: `Dotfiles/nvim/.config/nvim/colorschemes/Catppuccin.lua`
- Create: `Dotfiles/nvim/.config/nvim/colorschemes/Everforest.lua`
- Create: `Dotfiles/nvim/.config/nvim/colorschemes/Gruvbox.lua`
- Create: `Dotfiles/nvim/.config/nvim/colorschemes/TokyoNight.lua`
- Create: `Dotfiles/nvim/.config/nvim/colorschemes/Neon.lua`
- Create (symlink): `Dotfiles/nvim/.config/nvim/lua/plugins/colorscheme.lua` → `../../colorschemes/Gruvbox.lua`

**Interfaces:**
- Consumes: nothing new from Task 3.
- Produces: `lua/plugins/colorscheme.lua` symlink target — Task 5's `safe_link` calls repoint this same symlink; the five colorscheme names below (`catppuccin`, `everforest`, `gruvbox`, `tokyonight-night`, `tokyonight-storm`) are the exact strings Task 5's bash `case` block must reproduce.

- [ ] **Step 1: Write each theme's plugin spec**

```lua
-- colorschemes/Catppuccin.lua
return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha" },
  },
}
```

```lua
-- colorschemes/Everforest.lua
return {
  { "sainnhe/everforest", priority = 1000 },
  {
    "LazyVim/LazyVim",
    init = function()
      vim.g.everforest_background = "hard"
    end,
    opts = { colorscheme = "everforest" },
  },
}
```

```lua
-- colorschemes/Gruvbox.lua
return {
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox" },
  },
}
```

```lua
-- colorschemes/TokyoNight.lua
return {
  { "folke/tokyonight.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-night" },
  },
}
```

```lua
-- colorschemes/Neon.lua
-- No dedicated "Neon" nvim colorscheme exists; reuses tokyonight's storm
-- variant (distinct from TokyoNight.lua's "night" variant) per design decision.
return {
  { "folke/tokyonight.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-storm" },
  },
}
```

- [ ] **Step 2: Symlink the default (matches current active system theme, Gruvbox)**

```bash
cd ~/Documents/Dev/Dotfiles/nvim/.config/nvim
ln -sfn ../../colorschemes/Gruvbox.lua lua/plugins/colorscheme.lua
```

Note: run from inside `lua/plugins/`, so the relative target must be `../../colorschemes/Gruvbox.lua` relative to `lua/plugins/colorscheme.lua` — verify with the readlink check in Step 4 below rather than assuming the path math is right.

- [ ] **Step 3: Sync plugins and verify Gruvbox loads**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless -c "redir! > /tmp/colorscheme-check.txt" -c "echo g:colors_name" -c "redir END" -c "qa"
cat /tmp/colorscheme-check.txt
```

Expected: prints `gruvbox`.

- [ ] **Step 4: Verify the symlink resolves correctly**

```bash
readlink -f ~/Documents/Dev/Dotfiles/nvim/.config/nvim/lua/plugins/colorscheme.lua
```

Expected: `/home/kevin/Documents/Dev/Dotfiles/nvim/.config/nvim/colorschemes/Gruvbox.lua`

- [ ] **Step 5: Spot-check one more theme loads on demand (does not need to be the linked default — just confirms the plugin is installed and colorscheme name is valid)**

```bash
nvim --headless -c "colorscheme tokyonight-storm" -c "redir! > /tmp/neon-check.txt" -c "echo g:colors_name" -c "redir END" -c "qa"
cat /tmp/neon-check.txt
```

Expected: prints `tokyonight-storm`, no error about missing colorscheme.

- [ ] **Step 6: Commit**

```bash
cd ~/Documents/Dev/Dotfiles
git add nvim/.config/nvim/colorschemes/ nvim/.config/nvim/lua/plugins/colorscheme.lua nvim/.config/nvim/lazy-lock.json
git commit -m "feat: add per-theme nvim colorscheme specs"
```

---

### Task 5: Wire theme_select.sh for persistence + live reload

**Files:**
- Modify: `Dotfiles/hypr/.config/hypr/scripts/theme_select.sh:78` (existing `safe_link` block) and `:85-96` (existing live-reload block)

**Interfaces:**
- Consumes: `safe_link` helper (already defined at `theme_select.sh:64-71`), colorscheme names from Task 4 (`catppuccin-mocha`, `everforest`, `gruvbox`, `tokyonight-night`, `tokyonight-storm` — note: use the *full* opts value here, not the bare plugin name, since `:colorscheme` needs the exact registered scheme name).
- Produces: nothing consumed further — this is the last task.

- [ ] **Step 1: Add the nvim safe_link call next to the existing ones (after line 78, the waybar line)**

Existing block (`theme_select.sh:73-79`):

```bash
# Apply UI Themes
safe_link "$HOME/.config/hypr/confs/themes/${theme}.conf" "$HOME/.config/hypr/confs/decoration.conf"
safe_link "$HOME/.config/rofi/colors/${theme}.rasi" "$HOME/.config/rofi/themes/rofi-colors.rasi"
safe_link "$HOME/.config/kitty/colors/${theme}.conf" "$HOME/.config/kitty/theme.conf"
safe_link "$HOME/.config/ghostty/colors/${theme}.conf" "$HOME/.config/ghostty/theme.conf"
safe_link "$HOME/.config/waybar/colors/${theme}.css" "$HOME/.config/waybar/style/theme.css"
safe_link "$HOME/.config/wlogout/colors/${theme}.css" "$HOME/.config/wlogout/colors.css"
```

New line to add directly below it:

```bash
safe_link "$HOME/.config/nvim/colorschemes/${theme}.lua" "$HOME/.config/nvim/lua/plugins/colorscheme.lua"
```

- [ ] **Step 2: Add the nvim colorscheme name mapping + live-reload loop, placed after the existing Ghostty reload block (after line 96, before the "Setting VS Code / Kvantum theme" comment on line 98)**

```bash
# Apply new colorscheme dynamically to any running Neovim instances
case "$theme" in
    Catppuccin) nvimColorscheme="catppuccin-mocha" ;;
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

- [ ] **Step 3: Verify persistence — symlink updates on theme switch**

Run the script's core logic directly (bypassing the rofi picker) to test the Everforest path:

```bash
theme="Everforest"
source_file="$HOME/.config/nvim/colorschemes/${theme}.lua"
target_link="$HOME/.config/nvim/lua/plugins/colorscheme.lua"
[[ -f "$source_file" ]] && ln -sf "$source_file" "$target_link"
readlink -f "$target_link"
```

Expected: `/home/kevin/Documents/Dev/Dotfiles/nvim/.config/nvim/colorschemes/Everforest.lua`

- [ ] **Step 4: Verify live reload — open Neovim, switch theme, confirm it repaints without restart**

```bash
nvim --headless --listen /tmp/nvim-test.sock &
sleep 1
nvim --server /tmp/nvim-test.sock --remote-send ":colorscheme everforest<CR>"
sleep 1
nvim --server /tmp/nvim-test.sock --remote-expr "g:colors_name"
nvim --server /tmp/nvim-test.sock --remote-send ":qa!<CR>"
```

Expected: the `--remote-expr` call prints `everforest`.

- [ ] **Step 5: Restore the default symlink back to the actual active theme (Gruvbox) so the repo state matches reality post-testing**

```bash
ln -sf "$HOME/.config/nvim/colorschemes/Gruvbox.lua" "$HOME/.config/nvim/lua/plugins/colorscheme.lua"
```

- [ ] **Step 6: Full end-to-end pass through the real script for all 5 themes**

For each of `Catppuccin`, `Everforest`, `Gruvbox`, `Neon`, `TokyoNight`: run `~/Documents/Dev/Dotfiles/hypr/.config/hypr/scripts/theme_select.sh`, pick the theme in the rofi picker, and confirm:
- `readlink -f ~/.config/nvim/lua/plugins/colorscheme.lua` points at the matching `colorschemes/<theme>.lua`.
- A Neovim instance opened *before* the switch shows the new colorscheme immediately (check `:echo g:colors_name`).
- A Neovim instance opened *after* the switch starts directly in the new colorscheme.
- Background stays transparent (Kitty's translucency visible through Neovim) in all 5.

Finish on `Gruvbox` (the machine's actual current theme) so the repo's committed symlink matches live state.

- [ ] **Step 7: Commit**

```bash
cd ~/Documents/Dev/Dotfiles
git add hypr/.config/hypr/scripts/theme_select.sh nvim/.config/nvim/lua/plugins/colorscheme.lua
git commit -m "feat: wire theme_select.sh to nvim colorscheme (persist + live reload)"
```
