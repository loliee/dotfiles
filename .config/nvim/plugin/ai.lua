-- Sends a selection and an instruction to an AI CLI: a change opens as a diff, an answer in a Markdown split; r replies

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

-- The whole exchange goes in every prompt: the CLIs run without a session, the same way for Claude and Copilot
local function build_prompt(request)
  local parts = {
    "The text below comes from a " .. (request.filetype ~= "" and request.filetype or "text") .. " file.",
    "If the last instruction asks to change it, reply with the new text only: no explanation, no Markdown code fence,",
    "and keep the indentation. Otherwise, to answer a question, explain, or ask for missing details, reply with a",
    "first line ANSWER, then your answer in Markdown.",
    "Text:",
    table.concat(request.lines, "\n"),
  }
  for _, turn in ipairs(request.turns) do
    table.insert(parts, "Instruction: " .. turn.instruction)
    if turn.reply then
      table.insert(parts, "Your reply: " .. turn.reply)
    end
  end
  return table.concat(parts, "\n")
end

local send

local function close_view(request)
  if request.view and vim.api.nvim_buf_is_valid(request.view) then
    vim.api.nvim_buf_delete(request.view, { force = true })
  end
end

local function setup_view(request, scratch, filetype)
  vim.bo[scratch].bufhidden = "wipe"
  vim.bo[scratch].modifiable = false
  vim.bo[scratch].filetype = filetype
  request.view = scratch
  vim.keymap.set("n", "q", function()
    close_view(request)
  end, { buffer = scratch, desc = "Close the AI view" })
  vim.keymap.set("n", "r", function()
    vim.ui.input({ prompt = "Reply to " .. request.cli .. ": " }, function(instruction)
      if instruction and instruction ~= "" then
        table.insert(request.turns, { instruction = instruction })
        send(request)
      end
    end)
  end, { buffer = scratch, desc = "Reply to the AI" })
end

local function show_answer(request)
  local lines = {}
  for _, turn in ipairs(request.turns) do
    vim.list_extend(lines, { "> " .. turn.instruction, "" })
    vim.list_extend(lines, turn.kind == "answer" and vim.split(turn.reply, "\n") or { "_A change, shown as a diff_" })
    table.insert(lines, "")
  end
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, true, lines)
  setup_view(request, scratch, "markdown")

  local win = vim.fn.bufwinid(request.bufnr)
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
  end
  vim.cmd("vertical sbuffer " .. scratch)
  vim.wo.wrap = true
  vim.wo.linebreak = true
end

local function show_change(request, change)
  local win = vim.fn.bufwinid(request.bufnr)
  if win == -1 then
    return vim.notify("ai: the buffer is no longer shown, answer dropped", vim.log.levels.WARN)
  end

  local proposed = vim.list_slice(vim.api.nvim_buf_get_lines(request.bufnr, 0, -1, true), 1, request.first - 1)
  vim.list_extend(proposed, change)
  vim.list_extend(proposed, vim.api.nvim_buf_get_lines(request.bufnr, request.last, -1, true))

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, true, proposed)
  setup_view(request, scratch, vim.bo[request.bufnr].filetype)

  vim.api.nvim_set_current_win(win)
  vim.cmd.diffthis()
  vim.cmd("vertical sbuffer " .. scratch)
  vim.cmd.diffthis()

  vim.keymap.set("n", "<CR>", function()
    if vim.api.nvim_buf_get_changedtick(request.bufnr) ~= request.tick then
      return vim.notify("ai: the buffer changed, answer not applied", vim.log.levels.WARN)
    end
    vim.api.nvim_buf_set_lines(request.bufnr, request.first - 1, request.last, true, change)
    close_view(request)
  end, { buffer = scratch, desc = "Apply the AI change" })
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

send = function(request)
  local prompt = build_prompt(request)
  require("security").leaks(prompt, function(leaks)
    if leaks then
      return vim.notify("ai: the prompt holds a secret, nothing sent", vim.log.levels.WARN)
    end
    vim.notify("ai: waiting for " .. request.cli)
    vim.system(
      command(request.cli, prompt),
      { text = true },
      vim.schedule_wrap(function(result)
        if result.code ~= 0 then
          return vim.notify("ai: " .. request.cli .. " failed: " .. result.stderr, vim.log.levels.ERROR)
        end
        local output = result.stdout:gsub("\n+$", "")
        local answer = output:match("^ANSWER:?[ \t]*\n(.*)")
        local turn = request.turns[#request.turns]
        turn.kind = answer and "answer" or "change"
        turn.reply = answer or output
        if not answer and vim.api.nvim_buf_get_changedtick(request.bufnr) ~= request.tick then
          return vim.notify("ai: the buffer changed, answer dropped", vim.log.levels.WARN)
        end
        close_view(request)
        if answer then
          show_answer(request)
        else
          show_change(request, vim.split(output, "\n"))
        end
      end)
    )
  end)
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
    send({
      cli = cli,
      bufnr = bufnr,
      first = first,
      last = last,
      tick = vim.api.nvim_buf_get_changedtick(bufnr),
      filetype = vim.bo[bufnr].filetype,
      lines = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, true),
      turns = { { instruction = instruction } },
    })
  end)
end

local mappings = {
  { key = "<leader>cc", provider = "claude", desc = "Ask Claude to change or explain the selection" },
  { key = "<leader>co", provider = "copilot", desc = "Ask Copilot to change or explain the selection" },
}

for _, m in ipairs(mappings) do
  vim.keymap.set("v", m.key, function()
    ask(m.provider)
  end, { desc = m.desc, noremap = true, silent = true })
end
