return {
  "towolf/vim-helm",
  lazy = true,
  init = function()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*/helm-charts/*" },
      callback = function()
        require("lazy").load({ plugins = { "vim-helm" } })
      end,
    })
  end,
}
