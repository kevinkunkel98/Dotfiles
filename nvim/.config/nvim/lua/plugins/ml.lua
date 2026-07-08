return {
  -- configure pyright for ML (relax strict type checking)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
              },
            },
          },
        },
      },
    },
  },

  -- conda + venv switching via <leader>cv
  {
    "linux-cultist/venv-selector.nvim",
    opts = {},
  },

  -- inline plot/image output (ghostty supports kitty graphics protocol)
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width = 100,
      max_height = 20,
    },
  },

  -- run python cells inline like a notebook
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
    end,
    keys = {
      { "<leader>mi", ":MoltenInit<CR>",                              desc = "Molten: Init kernel" },
      { "<leader>ml", ":MoltenEvaluateLine<CR>",                      desc = "Molten: Eval line" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>",                    desc = "Molten: Re-eval cell" },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>",  mode = "v", desc = "Molten: Eval visual" },
      { "<leader>md", ":MoltenDelete<CR>",                            desc = "Molten: Delete cell" },
      { "<leader>mo", ":MoltenShowOutput<CR>",                        desc = "Molten: Show output" },
    },
  },

  -- debugger for training scripts
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      -- uses the active venv's python (set via venv-selector)
      local python = vim.fn.exepath("python3")
      require("dap-python").setup(python)
    end,
    keys = {
      { "<leader>dPt", function() require("dap-python").test_method() end,  desc = "Debug: Test method" },
      { "<leader>dPc", function() require("dap-python").test_class() end,   desc = "Debug: Test class" },
    },
  },
}
