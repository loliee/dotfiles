---
return {
  "zbirenbaum/copilot.lua",
  cmd = { "CopilotEnable", "CopilotDisable" },
  cond = function()
    return vim.g.copilot_disable == false
  end,
  keys = {
    {
      "<Leader>ce",
      "<cmd>Copilot enable<cr>",
    },
    {
      "<Leader>cd",
      "<cmd>Copilot disable<cr>",
    },
  },
  config = function()
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
  end,
}
