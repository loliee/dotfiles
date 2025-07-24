-- Ensures that every time a terminal opens, Neovim switches to insert mode
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert",
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Ensures the terminal buffer is automatically closed when the process exits.
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*",
  callback = function(event)
    if vim.fn.getbufvar(event.buf, "&buftype") == "terminal" then
      vim.api.nvim_buf_delete(event.buf, { force = true })
    end
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local patterns = { "COMMIT_EDITMSG", "MERGE_MSG", "REBASE_HEAD", "git-rebase-todo" }
    local file_name = vim.fn.expand("%:t")
    -- Don't restore position in git operations
    for _, pattern in ipairs(patterns) do
      if file_name == pattern then
        return
      end
    end
    local last_pos = vim.fn.line("'\"")
    if last_pos > 1 and last_pos <= vim.fn.line("$") then
      vim.api.nvim_exec('normal! g`"', false)
    end
  end,
})

-- Disable conform (file formatter)
vim.keymap.set("n", "<leader>sd", function()
  require("conform").setup({ enabled = false })
  print("Conform disabled")
end)

-- Git templates
-- Ensure syntax highlighting for lines starting with '
local global_syntax_group = vim.api.nvim_create_augroup("GlobalSyntax", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = global_syntax_group,
  pattern = { "COMMIT_EDITMSG", "MERGE_MSG", "REBASE_HEAD", "git-rebase-todo" },
  callback = function()
    vim.cmd([[
          syntax match gitComment "^'.*"
          highlight link gitComment Comment
          setlocal spell
        ]])
    vim.cmd("highlight Identifier guifg=#ff875f guibg=NONE")
    vim.cmd("highlight String guifg=#c9cac0 guibg=NONE")
    vim.cmd("highlight DiffAdd guifg=#82c476 guibg=NONE")
    vim.cmd("syntax match DiffAdd '^+.*$'")
    vim.cmd("highlight DiffRemove guifg=#f0522a guibg=NONE")
    vim.cmd("syntax match DiffRemove '^-.*$'")
    vim.cmd("highlight DiffChange guifg=#c9cac0 guibg=NONE")
    vim.cmd("syntax match DiffChange '^ .*'")
  end,
})
