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
