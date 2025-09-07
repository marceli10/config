return {
  -- Notification backend
  {
    "rcarriga/nvim-notify",
    opts = {
        stages = "fade",
        timeout = 3000,
        render = "default",
        top_down = true,
    },
  },

  -- Noice UI
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
          progress = { enabled = true },
          signature = { enabled = true },
          hover = { enabled = true },
        },
        messages = {
          enabled = true,
        },
        notify = {
          enabled = true,
        },
        views = {
          notify = {
            backend = "notify",
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
    },
  },
}

