local function copy_node_path(mode)
  return function(state)
    local path = state.tree:get_node():get_id()

    if mode == "relative" then
      path = vim.fn.fnamemodify(path, ":.")
    end

    vim.fn.setreg("+", path, "c")
    vim.notify(("Copied %s path: %s"):format(mode, path))
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          hide_hidden = false,
          hide_by_name = {},
          hide_by_pattern = {},
        },
        use_libuv_file_watcher = true,
      },
      window = {
        position = "left",
        width = 32,
        mappings = {
          ["gy"] = {
            copy_node_path("relative"),
            desc = "Copy CWD-relative path",
          },
          ["gY"] = {
            copy_node_path("absolute"),
            desc = "Copy absolute path",
          },
        },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
  },
}
