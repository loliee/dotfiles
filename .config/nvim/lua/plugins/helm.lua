return {
  "towolf/vim-helm",
  ft = { "helm" },
  lazy = true,
  init = function()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      callback = function()
        require("lazy").load({ plugins = { "vim-helm" } })
      end,
    })
  end,
}
