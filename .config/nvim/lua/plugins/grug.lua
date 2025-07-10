return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({ opts = {
      keymaps = {
        close = { n = "<localleader>q" },
      },
    } })
  end,
}
