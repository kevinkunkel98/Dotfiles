# Waybar Macchiato Restyle — Design Spec

**Date:** 2026-06-27  
**Goal:** Restyle `full-top` waybar to match the visual aesthetic of garuda-hyprdots, keeping all existing modules.

## Reference

https://github.com/yurihikari/garuda-hyprdots — Catppuccin Macchiato palette, transparent window, floating solid-background module pills.

## Files Modified

| File | Change |
|---|---|
| `~/.config/waybar/colors/Catppuccin.css` | Add Macchiato named color variables |
| `~/.config/waybar/style/full-top.css` | Restyle window, modules, and per-module accents |

## Backups

Before applying, copy each file to `<filename>.bak` so the original state is one rename away.

## 1. Color Variables (`Catppuccin.css`)

Append Catppuccin Macchiato semantic names alongside existing terminal palette vars (existing `@foreground`/`@background`/`@colorN` are preserved):

```css
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

## 2. Window & Global (`full-top.css`)

### Global font size
`15px` → `16px`

### `window#waybar`
- Remove `background: rgba(39, 48, 52, 0.432)` → `background-color: transparent`
- Remove `border-radius: 20px`

### Shared module selector (all module IDs)
- `background: @background` → `background-color: @base`
- `opacity: 0.8` → `opacity: 1`
- Add `border-radius: 10px`

## 3. Border Radius Standardisation

All individual `15px` overrides → `10px`. Grouped modules (left-only / right-only radius) updated proportionally:

| Selector | Old | New |
|---|---|---|
| `#idle_inhibitor` | `15px 0 0 15px` | `10px 0 0 10px` |
| `#custom-clipboard` | `0 15px 15px 0` | `0 10px 10px 0` |
| `#pulseaudio` | `15px 0 0 15px` | `10px 0 0 10px` |
| `#pulseaudio.microphone` | `0 15px 15px 0` | `0 10px 10px 0` |
| `#custom-light_dark` | `15px 0 0 15px` | `10px 0 0 10px` |
| `#mpris` | `15px` | `10px` |
| `#custom-notify` | `15px` | `10px` |
| `#custom-power_btn` | `15px` | `10px` |
| `#taskbar` | `15px` | `10px` |
| `#workspaces` | `15px` | `10px` |
| `#clock` | `15px` | `10px` |
| `#custom-updater` | `15px` | `10px` |
| `#custom-launch_rofi` | `15px` | `10px` |
| `#custom-lock_screen` | `15px` | `10px` |
| `#window` | `15px` | `10px` |

## 4. Per-Module Accent Colors

| Module | Property | Value | Reason |
|---|---|---|---|
| `#clock` | `color` | `@sky` | matches reference |
| `#workspaces button` | `color` | `@mauve` | reference workspace color |
| `#workspaces button.active` | `background` | `@mauve` | reference active state |
| `#workspaces button.active` | `color` | `@base` | dark icon on mauve |
| `#workspaces button.active` | `border-radius` | `50%` | circular active indicator |
| `#pulseaudio` | `color` | `@flamingo` | matches reference |
| `#network` | `color` | `@green` | matches reference |
| `#mpris` | `color` | `@lavender` | gentle music accent |
| `#custom-launch_rofi` | `background-color` | `@mauve` | reference launcher style |
| `#custom-launch_rofi` | `color` | `@base` | dark icon on mauve bg |
| `#custom-power_btn` | `background-color` | `@red` | reference: red bg, not red text |
| `#custom-power_btn` | `color` | `@base` | dark icon on red bg |

### Transparent modules (unchanged)
`#battery`, `#backlight`, `#network`, `#tray`, `#memory`, `#cpu`, `#disk`, `#temperature`, `#custom-system` — these already have explicit `background-color: transparent` overrides; they keep floating as icon-only elements.

## Rollback

```bash
cp ~/.config/waybar/style/full-top.css.bak ~/.config/waybar/style/full-top.css
cp ~/.config/waybar/colors/Catppuccin.css.bak ~/.config/waybar/colors/Catppuccin.css
pkill waybar; waybar &>/dev/null &
```
