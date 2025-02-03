return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion" },
  opts = {
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "claude-3.7-sonnet",
            },
          },
        })
      end,
    },
    opts = {
      -- Set debug logging
      log_level = "DEBUG",
    },
    strategies = {
      chat = {
        keymaps = {
          previous_chat = {
            modes = { n = "<C-x>", i = "<C-x>" },
          },
          send = {
            modes = { n = "<CR>", i = "<C-s>" },
          },
          close = {
            modes = { n = "<C-x>", i = "<C-x>" },
          },
          -- Add further custom keymaps here
        },
        slash_commands = {
          ["file"] = {
            -- Location to the slash command in CodeCompanion
            callback = "strategies.chat.slash_commands.file",
            description = "Select a file using Telescope",
            opts = {
              provider = "telescope",
              contains_code = true,
            },
          },
        },
      },
      inline = {
        adapter = "copilot",
        keymaps = {
          accept_change = {
            modes = { n = "ga" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gr" },
            description = "Reject the suggested change",
          },
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
