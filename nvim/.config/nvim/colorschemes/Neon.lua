-- No dedicated "Neon" nvim colorscheme exists; reuses tokyonight's storm
-- variant (distinct from TokyoNight.lua's "night" variant) per design decision.
return {
  { "folke/tokyonight.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-storm" },
  },
}
