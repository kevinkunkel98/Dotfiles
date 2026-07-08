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

local function set_transparent()
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

-- Apply on startup
set_transparent()

-- Re-apply on ColorScheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
  callback = set_transparent,
})
