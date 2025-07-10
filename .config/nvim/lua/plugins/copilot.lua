---
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  keys = {
    {
      "<Leader>ce",
      function()
        if vim.g.copilot_disable ~= false then
          error("Copilot cannot be enabled because COPILOT_DISABLE is defined!")
          return false
        end
        local ok = pcall(require, "copilot")
        if not ok then
          vim.notify("Failed to load Copilot", vim.log.levels.ERROR)
          return
        end
        require("copilot").setup({
          panel = {
            enabled = false,
            auto_refresh = false,
            layout = {
              position = "bottom",
              ratio = 0.4,
            },
          },
          suggestion = {
            enabled = false,
            auto_trigger = true,
            debounce = 75,
            keymap = {
              accept = false,
              accept_word = false,
              accept_line = false,
            },
          },
          filetypes = {
            help = false,
            gitcommit = false,
            gitrebase = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            sh = function()
              if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
                return false
              end
              return true
            end,
            ["."] = false,
          },
        })
        local success = pcall(vim.cmd, "Copilot enable")
        if success then
          vim.cmd("CodeCompanion<CR>")
          vim.cmd("CodeCompanionChat")
          print("Copilot enabled & CodeCompanionChat started!")
        else
          print("Failed to enable Copilot. Try restarting Neovim.")
        end
      end,
      desc = "Enable Copilot and start CodeCompanionChat",
      noremap = true,
      silent = true,
    },
    {
      "<leader>cd",
      function()
        vim.cmd("Copilot disable")
        vim.b.copilot_enabled = false
        print("Copilot disabled!")
      end,
      desc = "Disable copilot",
    },
  },
  dependencies = {
    {
      "zbirenbaum/copilot-cmp",
      config = function()
        require("copilot_cmp").setup()
      end,
    },
  },
}
