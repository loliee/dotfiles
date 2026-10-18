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

-- Conflict markers break every linter and server: hide the buffer's diagnostics until a write leaves none
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("conflict-diagnostics", { clear = true }),
  callback = function(args)
    local conflicted = vim.api.nvim_buf_call(args.buf, function()
      return vim.fn.search([[^\(<<<<<<<\|>>>>>>>\) ]], "nw") > 0
    end)
    if conflicted then
      vim.b[args.buf].conflict_diagnostics_off = true
      vim.diagnostic.enable(false, { bufnr = args.buf })
    elseif vim.b[args.buf].conflict_diagnostics_off then
      vim.b[args.buf].conflict_diagnostics_off = nil
      vim.diagnostic.enable(true, { bufnr = args.buf })
    end
  end,
})

-- Share a new terminal size between the windows of every tab, such as after a tmux zoom
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("equalize-on-resize", { clear = true }),
  callback = function()
    local tab = vim.api.nvim_get_current_tabpage()
    vim.cmd("tabdo wincmd =")
    vim.api.nvim_set_current_tabpage(tab)
  end,
})

-- Toggle conform's format on save
vim.keymap.set("n", "<leader>sd", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  print("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
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
    -- Groups of their own: highlight is global, so redefining DiffAdd or DiffChange here changes every diff
    vim.cmd("highlight gitMessageAdded guifg=#82c476 guibg=NONE")
    vim.cmd("syntax match gitMessageAdded '^+.*$'")
    vim.cmd("highlight gitMessageRemoved guifg=#f0522a guibg=NONE")
    vim.cmd("syntax match gitMessageRemoved '^-.*$'")
    vim.cmd("highlight gitMessageContext guifg=#c9cac0 guibg=NONE")
    vim.cmd("syntax match gitMessageContext '^ .*'")
  end,
})
