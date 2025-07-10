return {
  "folke/tokyonight.nvim",
  priority = 1000,
  init = function()
    vim.cmd.colorscheme("tokyonight")
    vim.cmd.hi("Comment gui=none")
  end,
  opts = {
    on_colors = require("plugins.patatetoy.colors"),
    on_highlights = require("plugins.patatetoy.highlights"),
  },
}
