-- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  cond = function()
    return vim.g.copilot_disable == false
  end,
  keys = {
    {
      "<leader>c",
      "<cmd>CodeCompanion<cr>",
      desc = "Run CodeCompanion command",
      mode = { "n", "v" },
    },
    {
      "<leader>ca",
      "<cmd>CodeCompanionActions<cr>",
      desc = "Run CodeCompanionActions command",
    },
    {
      "<leader>cc",
      "<cmd>CodeCompanionChat<cr>",
      desc = "Run CodeCompanionChat command",
    },
  },
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-lua/plenary.nvim" },
    { "ravitemer/codecompanion-history.nvim" },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
      },
      extensions = {
        history = {
          enabled = true,
        },
      },
    })
  end,
}
