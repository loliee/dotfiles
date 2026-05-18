return {
  "toppair/peek.nvim",
  event = { "VeryLazy" },
  build = "deno task --quiet build:fast",
  config = function()
    require("peek").setup({
      auto_load = true,
      close_on_bdelete = true,
      syntax = true,
      theme = "light",
      update_on_change = true,
      app = "browser",
      throttle_at = 200000,
      throttle_time = "auto",
    })
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  end,
  keys = {
    {
      "<Leader>m",
      "<cmd>PeekOpen<cr>",
      desc = "Open Peek Markdown preview",
      noremap = true,
    },
    {
      "<Leader>mc",
      "<cmd>PeekClose<cr>",
      desc = "Close Peek Markdown preview",
      noremap = true,
    },
  },
}
