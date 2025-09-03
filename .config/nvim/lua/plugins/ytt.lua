return {
  ft = { "yaml" },
  "carvel-dev/ytt.vim",
  dependencies = {
    "cappyzawa/starlark.vim",
  },
  config = function()
    local ytt_enabled = false
    vim.keymap.set("n", "<leader>y", function()
      if ytt_enabled then
        vim.cmd("DisableYtt")
        vim.bo.filetype = "yaml"
        ytt_enabled = false
        print("DisableYtt")
      else
        vim.cmd("set filetype=ytt")
        vim.cmd("EnableYtt")
        ytt_enabled = true
        print("EnableYtt")
      end
    end, { noremap = true, silent = true })
  end,
}
