return {
  -- File-level diffs, change lists, and commit history browsing (VSCode "diff" view).
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
    },
    opts = {},
  },

  -- Magit-style status panel: stage/unstage/commit/push/pull/branch (VSCode "source control").
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit status panel" },
    },
    opts = {
      integrations = {
        diffview = true, -- use diffview as the diff viewer inside Neogit
        telescope = true,
      },
    },
  },
}
