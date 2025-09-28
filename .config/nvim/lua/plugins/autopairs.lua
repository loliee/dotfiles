return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = true,
  opts = {
    fast_wrap = {},
    disable_filetype = { "TelescopePrompt", "vim" },
  },
}
