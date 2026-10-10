-- Rewrites the selected lines through an AI CLI, then shows the answer as a diff: <CR> applies it, q drops it

local models = { claude = "haiku", copilot = "gpt-5-mini" }

local function command(cli, prompt)
  if cli == "claude" then
    -- Not --bare, which drops the OAuth login; manual replaces the default plan mode, made for planning a change
    return {
      "claude",
      "-p",
      "--safe-mode",
      "--permission-mode",
      "manual",
      "--tools",
      "",
      "--no-session-persistence",
      "--model",
      models.claude,
      prompt,
    }
  end
  -- An empty --available-tools leaves the model no tool
  return {
    "copilot",
    "-p",
    prompt,
    "-s",
    "--model",
    models.copilot,
    "--available-tools=",
    "--no-custom-instructions",
    "--disable-builtin-mcps",
    "--no-ask-user",
  }
end

local function build_prompt(instruction, filetype, lines)
  return table.concat({
    "Apply the instruction to the text below, taken from a " .. (filetype ~= "" and filetype or "text") .. " file.",
    "Reply with the new text only: no explanation, no Markdown code fence. Keep the indentation.",
    "Instruction: " .. instruction,
    "Text:",
    table.concat(lines, "\n"),
  }, "\n")
end

local function preview(bufnr, first, last, tick, answer)
  local win = vim.fn.bufwinid(bufnr)
  if win == -1 then
    return vim.notify("ai: the buffer is no longer shown, answer dropped", vim.log.levels.WARN)
  end

  local proposed = vim.list_slice(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), 1, first - 1)
  vim.list_extend(proposed, answer)
  vim.list_extend(proposed, vim.api.nvim_buf_get_lines(bufnr, last, -1, true))

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, true, proposed)
  vim.bo[scratch].bufhidden = "wipe"
  vim.bo[scratch].modifiable = false
  vim.bo[scratch].filetype = vim.bo[bufnr].filetype

  vim.api.nvim_set_current_win(win)
  vim.cmd.diffthis()
  vim.cmd("vertical sbuffer " .. scratch)
  vim.cmd.diffthis()

  local function close()
    vim.api.nvim_buf_delete(scratch, { force = true })
  end
  vim.keymap.set("n", "<CR>", function()
    if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
      return vim.notify("ai: the buffer changed, answer not applied", vim.log.levels.WARN)
    end
    vim.api.nvim_buf_set_lines(bufnr, first - 1, last, true, answer)
    close()
  end, { buffer = scratch, desc = "Apply the AI answer" })
  vim.keymap.set("n", "q", close, { buffer = scratch, desc = "Drop the AI answer" })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = scratch,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, vim.cmd.diffoff)
      end
    end,
  })
end

local function ask(cli)
  local bufnr = vim.api.nvim_get_current_buf()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)

  if require("security").secret(vim.api.nvim_buf_get_name(bufnr)) then
    return vim.notify("ai: this file holds secrets, nothing sent", vim.log.levels.WARN)
  end

  vim.ui.input({ prompt = "Instruction for " .. cli .. ": " }, function(instruction)
    if not instruction or instruction == "" then
      return
    end
    local tick = vim.api.nvim_buf_get_changedtick(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, true)
    local prompt = build_prompt(instruction, vim.bo[bufnr].filetype, lines)

    vim.notify("ai: waiting for " .. cli)
    vim.system(
      command(cli, prompt),
      { text = true },
      vim.schedule_wrap(function(result)
        if result.code ~= 0 then
          return vim.notify("ai: " .. cli .. " failed: " .. result.stderr, vim.log.levels.ERROR)
        end
        if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
          return vim.notify("ai: the buffer changed, answer dropped", vim.log.levels.WARN)
        end
        preview(bufnr, first, last, tick, vim.split((result.stdout:gsub("\n+$", "")), "\n"))
      end)
    )
  end)
end

local mappings = {
  { key = "<leader>cc", provider = "claude", desc = "Rewrite the selection with Claude" },
  { key = "<leader>co", provider = "copilot", desc = "Rewrite the selection with Copilot" },
}

for _, m in ipairs(mappings) do
  vim.keymap.set("v", m.key, function()
    ask(m.provider)
  end, { desc = m.desc, noremap = true, silent = true })
end
