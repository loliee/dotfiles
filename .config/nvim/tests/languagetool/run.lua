-- Run from anywhere: nvim --headless --clean -l .config/nvim/tests/languagetool/run.lua
-- The LanguageTool tests need the server on localhost:8081

local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(arg[0], ":p"))))
-- Not the config dir on the runtimepath: its queries/yaml needs a directive that only lua/plugins/treesitter.lua adds
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
local data = vim.fn.stdpath("data")
vim.opt.runtimepath:prepend(data .. "/site")
vim.opt.runtimepath:prepend(data .. "/lazy/nvim-treesitter/runtime")
-- The languages forced with :LanguageTool go there, away from the user's
vim.env.XDG_STATE_HOME = vim.fn.tempname()

local extract = require("languagetool.extract")
local languagetool = require("languagetool")

local failures = 0

local function test(name, fn)
  local ok, err = pcall(fn)
  print((ok and "ok   " or "FAIL ") .. name .. (ok and "" or "\n     " .. tostring(err)))
  if not ok then
    failures = failures + 1
  end
end

local function eq(actual, expected)
  if not vim.deep_equal(actual, expected) then
    error(("expected %s, got %s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local function buffer(filetype, lines)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo[buf].filetype = filetype
  return buf
end

-- What LanguageTool reads: the text, and markup as its interpretAs
local function plain(segment)
  local out = {}
  for _, a in ipairs(segment.annotations) do
    table.insert(out, a.text or a.interpretAs or "")
  end
  return table.concat(out)
end

-- Every segment must cover the buffer exactly, or offsets land on the wrong characters
local function segments(buf)
  local list = extract.segments(buf)
  local source = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, true), "\n") .. "\n"
  local starts = { 0 }
  for pos in source:gmatch("\n()") do
    table.insert(starts, pos - 1)
  end
  for _, s in ipairs(list) do
    local raw = {}
    for _, a in ipairs(s.annotations) do
      table.insert(raw, a.text or a.markup)
    end
    eq(table.concat(raw), s.text)
    local start = starts[s.row + 1] + s.col
    eq(source:sub(start + 1, start + #s.text), s.text)
  end
  return vim.tbl_map(plain, list)
end

local function diagnostics(buf, start)
  local done = false
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    buffer = buf,
    once = true,
    callback = function()
      done = true
    end,
  })
  start()
  assert(
    vim.wait(20000, function()
      return done
    end, 20),
    "no diagnostics: is LanguageTool up on localhost:8081?"
  )
  return vim.diagnostic.get(buf, { namespace = languagetool.ns })
end

local function find(diags, field, value)
  for _, d in ipairs(diags) do
    if (field == "text" and d.user_data.text or d[field]) == value then
      return d
    end
  end
  error(("no diagnostic with %s = %s in %s"):format(field, value, vim.inspect(diags)), 2)
end

-- The current buffer, with a file to keep the settings of :LanguageTool
local function file_buffer(filetype, lines)
  local path = vim.fn.tempname() .. ".lua"
  vim.fn.writefile({}, path)
  local buf = buffer(filetype, lines)
  vim.api.nvim_buf_set_name(buf, path)
  vim.api.nvim_set_current_buf(buf)
  return buf, vim.uv.fs_realpath(path)
end

local function settings()
  local file = vim.fs.joinpath(vim.env.XDG_STATE_HOME, "nvim", "languagetool.json")
  return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
end

-- The messages of a command
local function said(command)
  local notify, messages = vim.notify, {}
  vim.notify = function(message)
    table.insert(messages, message)
  end
  vim.cmd(command)
  vim.notify = notify
  return messages
end

test("lua: line comments merge, markers and code words are markup", function()
  local buf = buffer("lua", {
    "local x = 1 -- trailing note",
    "-- First line, see `vim.fn` and foo_bar.",
    "--",
    "-- Second paragraph about vim.api.nvim_buf_get_lines(), (see --flag).",
    "---@param x string",
    "print(x)",
  })
  eq(segments(buf), {
    "trailing note",
    "First line, see X and X. Second paragraph about X, (see X).",
  })
end)

test("bash: the shebang is skipped", function()
  -- Not sh: nvim-treesitter maps it to bash, and it is not loaded here
  local buf = buffer("bash", {
    "#!/usr/bin/env bash",
    "# Run it from /tmp with e.g. CamelCase.",
    "# Then #offset! moves it.",
    "echo hi # inline",
  })
  eq(segments(buf), { "Run it from X with X. X. Then X moves it.", "inline" })
end)

test("yaml: ytt annotations are markup", function()
  local buf = buffer("yaml", {
    '#@ load("@ytt:data", "data")',
    "#! Ce commentaire est vérifié.",
    "key: value",
  })
  eq(segments(buf), { "Ce commentaire est vérifié." })
end)

test("lua: block comment markers are markup", function()
  local buf = buffer("lua", {
    "--[[ Une note",
    "  sur deux lignes ]]",
  })
  eq(segments(buf), { "Une note sur deux lignes" })
end)

test("markdown: code, emphasis, underline, links and tables", function()
  local buf = buffer("markdown", {
    "# Un titre avec `code`",
    "",
    "Du **gras**, de l'_italique_, du <u>souligné</u> et un [lien](https://example.org).",
    "",
    "```lua",
    "-- pas vérifié",
    "```",
    "",
    "| Colonne A | Colonne B |",
    "| --------- | --------- |",
    "| une       | deux      |",
  })
  local got = segments(buf)
  got[3] = vim.trim(got[3])
  eq(got, {
    "Un titre avec X",
    "Du gras, de l'italique, du souligné et un lien.",
    "Colonne A\n\nColonne B\n\nune\n\ndeux",
  })
end)

test("markdown: continuation lines of quotes and lists", function()
  local buf = buffer("markdown", {
    "> Une citation",
    "> sur deux lignes.",
    "",
    "- Un élément",
    "  qui continue.",
  })
  eq(segments(buf), { "Une citation\nsur deux lignes.", "Un élément\nqui continue." })
end)

test("gitcommit: the subject and the body, not git's comments nor the diff of commit -v", function()
  local buf = buffer("gitcommit", {
    "Ensure rclone is installed",
    "",
    "The backup reads `rclone` and its config in .config/rclone.",
    "- One more point",
    "",
    "' Please enter the commit message for your changes.",
    "' ------------------------ >8 ------------------------",
    "' Do not modify or remove the line above.",
    "diff --git a/foo b/foo",
    "+a new line",
  })
  eq(segments(buf), {
    "Ensure rclone is installed",
    "The backup reads X and its config in X. One more point",
  })
end)

local lua_buf

test("languagetool: a fault after accents and an emoji, on the second line", function()
  lua_buf = buffer("lua", {
    "-- Une phrase correcte.",
    "-- 🎉 Été : il a finir.",
  })
  local diags = diagnostics(lua_buf, function()
    languagetool.check(lua_buf)
  end)
  local d = find(diags, "text", "finir")
  local col = vim.api.nvim_buf_get_lines(lua_buf, 1, 2, true)[1]:find("finir", 1, true) - 1
  eq({ d.lnum, d.col, d.end_lnum, d.end_col }, { 1, col, 1, col + #"finir" })
  eq(d.source, "languagetool")
  eq(d.severity, vim.diagnostic.severity.HINT)
  assert(vim.tbl_contains(d.user_data.replacements, "fini"), vim.inspect(d.user_data.replacements))
end)

test("languagetool: an English comment is checked in English", function()
  local buf = buffer("lua", { "-- Not lower: the probe would fails." })
  local diags = diagnostics(buf, function()
    languagetool.check(buf)
  end)
  find(diags, "code", "MD_BASEFORM")
end)

test("languagetool: a commit is checked in English, even when its words look French", function()
  local buf = buffer("gitcommit", { "Add the café de la gare page, the probe would fails" })
  local diags = diagnostics(buf, function()
    languagetool.check(buf)
  end)
  find(diags, "code", "MD_BASEFORM")
end)

test("languagetool: a word of the spellfile is not flagged, in any case", function()
  -- Where zg writes when 'spellfile' is empty, as at startup
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir .. "/spell", "p")
  -- zug overwrites the first character with #: mise once added, then removed
  vim.fn.writefile({ "dotfiles", "#ise", "Zorbix" }, dir .. "/spell/en.utf-8.add")
  vim.opt.runtimepath:prepend(dir)
  local buf = buffer("lua", { "-- The dotfiles and the Dotfiles use mise, ZORBIX and zorbix." })
  local diags = diagnostics(buf, function()
    languagetool.check(buf)
  end)
  vim.opt.runtimepath:remove(dir)
  vim.fn.delete(dir, "rf")
  find(diags, "text", "mise")
  -- As in Vim, Zorbix covers ZORBIX, not zorbix
  find(diags, "text", "zorbix")
  for _, d in ipairs(diags) do
    local text = d.user_data.text
    assert(text:lower() ~= "dotfiles" and text ~= "ZORBIX", "flagged a word of the spellfile: " .. vim.inspect(d))
  end
end)

test("languagetool: markdown inline code is not checked", function()
  local buf = buffer("markdown", { "Il a finir `du codee` ici." })
  local diags = diagnostics(buf, function()
    languagetool.check(buf)
  end)
  eq(find(diags, "text", "finir").col, 5)
  for _, d in ipairs(diags) do
    assert(d.col < 11, "flagged inside the code span: " .. vim.inspect(d))
  end
end)

test("blink: the replacements under the cursor, nothing once the text changed", function()
  local source = require("languagetool.blink").new()
  local line = vim.api.nvim_buf_get_lines(lua_buf, 1, 2, true)[1]
  local col = line:find("finir", 1, true) - 1
  local function complete()
    local items
    source:get_completions({ bufnr = lua_buf, cursor = { 2, col + 3 } }, function(response)
      items = response.items
    end)
    return items
  end

  local items = complete()
  local item = vim.iter(items):find(function(i)
    return i.label == "fini"
  end)
  assert(item, vim.inspect(items))
  eq(item.textEdit, {
    newText = "fini",
    range = { start = { line = 1, character = col }, ["end"] = { line = 1, character = col + #"finir" } },
  })
  eq(item.filterText, "finir")
  eq(item.kind_icon, languagetool.icon)

  vim.api.nvim_buf_set_text(lua_buf, 1, col, 1, col + #"finir", { "finit" })
  eq(complete(), {})
end)

test("blink: the replacements follow the edits made since the check", function()
  local buf = buffer("lua", { "-- Il a finir et elle a chanter." })
  diagnostics(buf, function()
    languagetool.check(buf)
  end)
  -- The first fix, as blink applies it, then a line added above
  local first = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]:find("finir", 1, true) - 1
  vim.api.nvim_buf_set_text(buf, 0, first, 0, first + #"finir", { "fini" })
  vim.api.nvim_buf_set_lines(buf, 0, 0, true, { "-- Une nouvelle ligne." })

  local col = vim.api.nvim_buf_get_lines(buf, 1, 2, true)[1]:find("chanter", 1, true) - 1
  local items
  require("languagetool.blink").new():get_completions({ bufnr = buf, cursor = { 2, col + 3 } }, function(response)
    items = response.items
  end)
  local item = vim.iter(items):find(function(i)
    return i.label == "chanté"
  end)
  assert(item, vim.inspect(items))
  eq(
    item.textEdit.range,
    { start = { line = 1, character = col }, ["end"] = { line = 1, character = col + #"chanter" } }
  )
end)

test("languagetool: a second check sends only the changed piece", function()
  local buf = buffer("lua", { "-- Il a finir.", "local x = 1", "-- Elle a chanter." })
  diagnostics(buf, function()
    languagetool.check(buf)
  end)
  local system, sent = vim.system, 0
  vim.system = function(...)
    sent = sent + 1
    return system(...)
  end
  vim.api.nvim_buf_set_lines(buf, 2, 3, true, { "-- Elle a dansé." })
  vim.api.nvim_buf_set_lines(buf, 0, 0, true, { "local y = 2" })
  local diags = diagnostics(buf, function()
    languagetool.check(buf)
  end)
  vim.system = system
  eq(sent, 1)
  eq(find(diags, "text", "finir").lnum, 1)
end)

test("languagetool: a busy machine pauses the automatic checks of a big buffer until resume", function()
  -- Any load is above 0 per core
  vim.g.languagetool = { pause_pieces = 1, pause_load = 0 }
  local buf = buffer("lua", { "-- Il a finir.", "local x = 1", "-- Elle a chanter." })
  languagetool.check(buf)
  eq(vim.b[buf].languagetool_paused, true)
  local diags = diagnostics(buf, function()
    languagetool.check(buf, { force = true })
  end)
  eq(vim.b[buf].languagetool_paused, nil)
  find(diags, "text", "finir")

  -- A forced check is a one-off: 2 changed pieces pause again
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "-- Tu a finir.", "local x = 1", "-- Nous a chanter." })
  languagetool.check(buf)
  eq(vim.b[buf].languagetool_paused, true)
  diagnostics(buf, function()
    languagetool.resume(buf)
  end)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "-- Vous a finir.", "local x = 1", "-- Ils a chanter." })
  diagnostics(buf, function()
    languagetool.check(buf)
    eq(vim.b[buf].languagetool_paused, nil)
  end)
  vim.g.languagetool = nil
end)

test("plugin: opening a file checks it, :LanguageTool exists", function()
  dofile(root .. "/plugin/languagetool.lua")
  assert(vim.api.nvim_get_commands({}).LanguageTool, "no :LanguageTool command")
  local path = vim.fn.tempname() .. ".lua"
  vim.fn.writefile({ "-- Il a finir." }, path)
  diagnostics(nil, function()
    vim.cmd.edit(path)
  end)
  find(vim.diagnostic.get(vim.fn.bufnr(path), { namespace = languagetool.ns }), "text", "finir")
  vim.fn.delete(path)
end)

test("plugin: :LanguageTool lang fr forces French on the file until :LanguageTool lang auto", function()
  local buf, path = file_buffer("lua", { "-- Not lower: the probe would fails." })
  eq(vim.fn.getcompletion("LanguageTool ", "cmdline"), { "disable", "enable", "lang", "resume" })
  eq(vim.fn.getcompletion("LanguageTool lang ", "cmdline"), { "auto", "en-US", "fr" })
  eq(vim.fn.getcompletion("LanguageTool lang f", "cmdline"), { "fr" })
  eq(said("LanguageTool lang"), { "languagetool: auto" })

  local diags = diagnostics(buf, function()
    vim.cmd("LanguageTool lang fr")
  end)
  eq(settings(), { [path] = { lang = "fr" } })
  -- French wants a space before the colon
  find(diags, "code", "FRENCH_WHITESPACE")
  eq(said("LanguageTool lang"), { "languagetool: fr, forced for this file" })

  eq(said("LanguageTool lang de"), { "languagetool: de is none of auto, en-US, fr" })
  eq(said("LanguageTool auto"), { "languagetool: auto is none of disable, enable, lang, resume" })
  eq(settings(), { [path] = { lang = "fr" } })

  diags = diagnostics(buf, function()
    vim.cmd("LanguageTool lang auto")
  end)
  eq(settings(), {})
  find(diags, "code", "MD_BASEFORM")
  vim.fn.delete(path)
end)

test("plugin: :LanguageTool disable turns the file off until :LanguageTool enable", function()
  local buf, path = file_buffer("lua", { "-- Il a finir." })
  diagnostics(buf, function()
    vim.cmd("LanguageTool")
  end)
  -- With a check under way, which disable drops
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "-- Elle a chanter." })
  languagetool.check(buf)
  vim.cmd("LanguageTool disable")
  eq(settings(), { [path] = { disabled = true } })
  eq(vim.b[buf].languagetool_disabled, true)
  -- Neither the dropped check, an automatic one nor :LanguageTool brings diagnostics back
  languagetool.check(buf)
  eq(said("LanguageTool"), { "languagetool: disabled for this file, :LanguageTool enable" })
  assert(not vim.wait(2000, function()
    return #vim.diagnostic.get(buf, { namespace = languagetool.ns }) > 0
  end, 20), "diagnostics on a disabled file")

  local diags = diagnostics(buf, function()
    vim.cmd("LanguageTool enable")
  end)
  eq(settings(), {})
  eq(vim.b[buf].languagetool_disabled, nil)
  find(diags, "text", "chanter")
  vim.fn.delete(path)
end)

os.exit(failures > 0 and 1 or 0)
