return {
  "norcalli/nvim-colorizer.lua",
  events = { "VeryLazy" },
  keys = {
    {
      "<leader>co",
      function()
        vim.cmd("ColorizerToggle")
      end,
      { desc = "Display hexa colors" },
    },
  },
}
