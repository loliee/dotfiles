return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({ opts = {
      keymaps = {
        close = { n = "<localleader>q" },
      },
    } })
  end,
  vim.keymap.set("n", "<leader>g", function()
    require("grug-far").open({ engine = "ripgrep" })
  end, { desc = "Open grug-far with ripgrep" }),
  vim.keymap.set("n", "<leader>ga", function()
    require("grug-far").open({ engine = "ripgrep" })
  end, { desc = "Open grug-far with ripgrep" }),
}
