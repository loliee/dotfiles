return {
  "toppair/peek.nvim",
  event = { "VeryLazy" },
  build = "deno task --quiet build:fast",
  opts = {},
  keys = {
    {
      "<Leader>o",
      function()
        require("peek").open()
      end,
      desc = "Open Peek Markdown preview",
      noremap = true,
    },
    {
      "<Leader>oc",
      function()
        require("peek").close()
      end,
      desc = "Close Peek Markdown preview",
      noremap = true,
    },
  },
}
