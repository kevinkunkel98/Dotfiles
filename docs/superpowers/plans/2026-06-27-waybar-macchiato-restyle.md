# Waybar Macchiato Restyle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the `full-top` waybar config to match the garuda-hyprdots aesthetic — transparent bar window, floating solid-background module pills, per-module Catppuccin Macchiato accent colors.

**Architecture:** Two files are modified sequentially. Color variables are added first so later CSS can reference them. Then `full-top.css` is updated in three passes: (1) window/global/background, (2) border-radius standardisation, (3) per-module accent colors and button inversions.

**Tech Stack:** Waybar (GTK CSS), Catppuccin Macchiato palette

## Global Constraints

- Only modify `~/.config/waybar/colors/Catppuccin.css` and `~/.config/waybar/style/full-top.css`
- Preserve all existing `@foreground`, `@background`, `@colorN` variables in Catppuccin.css
- No changes to waybar config (JSON) files — modules stay as-is
- Each task ends with a waybar restart to catch CSS parse errors early
- Rollback: `cp ~/.config/waybar/style/full-top.css.bak ~/.config/waybar/style/full-top.css && cp ~/.config/waybar/colors/Catppuccin.css.bak ~/.config/waybar/colors/Catppuccin.css && pkill waybar; sleep 0.5; waybar &>/dev/null &`

---

### Task 1: Backup + Add Macchiato Color Variables

**Files:**
- Backup: `~/.config/waybar/style/full-top.css` → `full-top.css.bak`
- Backup: `~/.config/waybar/colors/Catppuccin.css` → `Catppuccin.css.bak`
- Modify: `~/.config/waybar/colors/Catppuccin.css`

- [ ] **Step 1: Create backups**

```bash
cp ~/.config/waybar/style/full-top.css ~/.config/waybar/style/full-top.css.bak
cp ~/.config/waybar/colors/Catppuccin.css ~/.config/waybar/colors/Catppuccin.css.bak
```

- [ ] **Step 2: Append Macchiato named colors to Catppuccin.css**

Add to the end of `~/.config/waybar/colors/Catppuccin.css`:

```css
/* Catppuccin Macchiato semantic colors */
@define-color base     #24273a;
@define-color mantle   #1e2030;
@define-color mauve    #c6a0f6;
@define-color sky      #91d7e3;
@define-color flamingo #f0c6c6;
@define-color green    #a6da95;
@define-color lavender #b7bdf8;
@define-color red      #ed8796;
@define-color yellow   #eed49f;
@define-color peach    #f5a97f;
@define-color teal     #8bd5ca;
@define-color blue     #8aadf4;
```

- [ ] **Step 3: Verify waybar loads without errors**

```bash
pkill waybar; sleep 0.5; waybar &>/dev/null &
```

Expected: waybar restarts and bar appears. No visual change yet — the new color variables aren't referenced anywhere yet.

---

### Task 2: Transparent Window + Global Font + Background Updates

**Files:**
- Modify: `~/.config/waybar/style/full-top.css`

- [ ] **Step 1: Update global font size**

In the `*` selector (top of file), change:
```css
  font-size: 15px;
```
to:
```css
  font-size: 16px;
```

- [ ] **Step 2: Make window#waybar fully transparent**

Replace the entire `window#waybar` block:

Old:
```css
window#waybar {
  background: rgba(39, 48, 52, 0.432);
  color: @foreground;
  border-radius: 20px;
}
```

New:
```css
window#waybar {
  background-color: transparent;
  color: @foreground;
}
```

- [ ] **Step 3: Update the shared module selector**

The large comma-separated selector that ends with `#backlight {` has these properties — change them:

Old:
```css
  background: @background;
  opacity: 0.8;
  padding: 0px 10px;
  margin: 3px 0px;
```

New:
```css
  background-color: @base;
  opacity: 1;
  padding: 0px 10px;
  margin: 3px 0px;
  border-radius: 10px;
```

- [ ] **Step 4: Update #mpris individual background**

Old:
```css
#mpris {
  background-color: @background;
  border-radius: 15px;
  padding-left: 15px;
  margin-left: 10px;
}
```

New:
```css
#mpris {
  background-color: @base;
  border-radius: 15px;
  padding-left: 15px;
  margin-left: 10px;
}
```

- [ ] **Step 5: Update #pulseaudio individual background**

Old:
```css
#pulseaudio {
  background-color: @background;
  border-left: 0px;
  border-right: 0px;
  border-radius: 15px 0 0 15px;
}
```

New:
```css
#pulseaudio {
  background-color: @base;
  border-left: 0px;
  border-right: 0px;
  border-radius: 15px 0 0 15px;
}
```

- [ ] **Step 6: Restart waybar and verify**

```bash
pkill waybar; sleep 0.5; waybar &>/dev/null &
```

Expected: The unified pill-shaped bar background is gone — modules now float as individual dark (#24273a) pills directly against the wallpaper. Font is slightly larger across the bar.

---

### Task 3: Border Radius Standardisation (15px → 10px)

**Files:**
- Modify: `~/.config/waybar/style/full-top.css`

Make all of the following changes. Go through the file in order — each is an exact find-and-replace within its selector block.

- [ ] **Step 1: Apply all border-radius changes**

| Selector | Old value | New value |
|---|---|---|
| `#idle_inhibitor` | `border-radius: 15px 0 0 15px;` | `border-radius: 10px 0 0 10px;` |
| `#mpris` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-notify` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-clipboard` | `border-radius: 0 15px 15px 0;` | `border-radius: 0 10px 10px 0;` |
| `#custom-power_btn` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#taskbar` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-updater` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-launch_rofi` (first block) | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-lock_screen` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#custom-light_dark` | `border-radius: 15px 0 0 15px;` | `border-radius: 10px 0 0 10px;` |
| `#workspaces` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#window` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#pulseaudio` | `border-radius: 15px 0 0 15px;` | `border-radius: 10px 0 0 10px;` |
| `#clock` | `border-radius: 15px;` | `border-radius: 10px;` |
| `#pulseaudio.microphone` | `border-radius: 0 15px 15px 0;` | `border-radius: 0 10px 10px 0;` |

Note: `#temperature` already has `border-radius: 0 10px 10px 0` — leave it unchanged.

- [ ] **Step 2: Restart waybar and verify**

```bash
pkill waybar; sleep 0.5; waybar &>/dev/null &
```

Expected: Module corners are slightly sharper (10px vs 15px). Grouped modules (pulseaudio+mic, idle_inhibitor+clipboard) should still connect seamlessly on their shared edges.

---

### Task 4: Per-Module Accent Colors + Button Inversions

**Files:**
- Modify: `~/.config/waybar/style/full-top.css`

- [ ] **Step 1: Workspace buttons — mauve inactive color**

Old:
```css
#workspaces button {
  padding: 2px;
  color: @foreground;
  margin-right: 5px;
  background-color: rgba(17, 17, 27, 0);
}
```

New:
```css
#workspaces button {
  padding: 2px;
  color: @mauve;
  margin-right: 5px;
  background-color: rgba(17, 17, 27, 0);
}
```

- [ ] **Step 2: Workspace active button — circular mauve pill**

Old:
```css
#workspaces button.active {
  color: @background;
  background: @foreground;
  padding: 0 17px;
  margin: 3px 0;
  border-radius: 15px;
}
```

New:
```css
#workspaces button.active {
  color: @base;
  background: @mauve;
  padding: 0 10px;
  margin: 3px 0;
  border-radius: 50%;
}
```

- [ ] **Step 3: Workspace hover — mauve hover color**

Old:
```css
#workspaces button:hover {
  background: transparent;
  color: @color8;
  border: none;
}
```

New:
```css
#workspaces button:hover {
  background: transparent;
  color: @mauve;
  border: none;
}
```

- [ ] **Step 4: Clock — sky accent + fix font size override**

Old:
```css
#clock {
  border-radius: 10px;
  margin-right: 10px;
  margin-left: 10px;
  padding: 0 20px;
  font-size: 12px;
}
```

New:
```css
#clock {
  color: @sky;
  border-radius: 10px;
  margin-right: 10px;
  margin-left: 10px;
  padding: 0 20px;
  font-size: 16px;
}
```

- [ ] **Step 5: Pulseaudio — flamingo accent**

Old:
```css
#pulseaudio {
  background-color: @base;
  border-left: 0px;
  border-right: 0px;
  border-radius: 10px 0 0 10px;
}
```

New:
```css
#pulseaudio {
  color: @flamingo;
  background-color: @base;
  border-left: 0px;
  border-right: 0px;
  border-radius: 10px 0 0 10px;
}
```

- [ ] **Step 6: Network — green accent + fix font size override**

Old:
```css
#network,
#network.speed {
  background-color: transparent;
  font-size: 15px;
}
```

New:
```css
#network,
#network.speed {
  color: @green;
  background-color: transparent;
  font-size: 16px;
}
```

- [ ] **Step 7: Mpris — lavender accent**

Old:
```css
#mpris {
  background-color: @base;
  border-radius: 10px;
  padding-left: 15px;
  margin-left: 10px;
}
```

New:
```css
#mpris {
  color: @lavender;
  background-color: @base;
  border-radius: 10px;
  padding-left: 15px;
  margin-left: 10px;
}
```

- [ ] **Step 8: custom-launch_rofi — mauve background, dark icon**

First `#custom-launch_rofi` block (has padding/font-size/border-radius). Old:
```css
#custom-launch_rofi {
  margin-right: 10px;
  padding: 0 15px;
  padding-right: 20px;
  font-size: 15px;
  border-radius: 10px;
}
```

New:
```css
#custom-launch_rofi {
  background-color: @mauve;
  margin-right: 10px;
  padding: 0 15px;
  padding-right: 20px;
  font-size: 16px;
  border-radius: 10px;
}
```

Second `#custom-launch_rofi` block (has color/margin-left). Old:
```css
#custom-launch_rofi {
  color: @foreground;
  margin-left: 10px;
}
```

New:
```css
#custom-launch_rofi {
  color: @base;
  margin-left: 10px;
}
```

- [ ] **Step 9: custom-power_btn — red background, dark icon**

Old:
```css
#custom-power_btn {
  color: red;
  padding: 0 15px;
  padding-right: 20px;
  margin-right: 10px;
  border-radius: 10px;
  font-size: 15px;
  font-weight: bolder;
}
```

New:
```css
#custom-power_btn {
  color: @base;
  background-color: @red;
  padding: 0 15px;
  padding-right: 20px;
  margin-right: 10px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: bolder;
}
```

- [ ] **Step 10: Final restart and visual verification**

```bash
pkill waybar; sleep 0.5; waybar &>/dev/null &
```

Visual checklist:
- [ ] Bar background is fully transparent — no pill-shaped bar visible, just floating modules
- [ ] Module backgrounds are solid dark blue-grey (#24273a), not semi-transparent
- [ ] Clock text is cyan/sky coloured
- [ ] Audio module icon is pinkish/flamingo
- [ ] Network module text is green
- [ ] Mpris (Spotify) text is soft lavender/blue
- [ ] Active workspace button is a circular mauve pill
- [ ] Launcher button (left side) has a purple/mauve background with dark icon
- [ ] Power button (right end) has a soft pink-red background (#ed8796) with dark icon — NOT red text on dark background
