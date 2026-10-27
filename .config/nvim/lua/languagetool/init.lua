-- Checks a buffer with a LanguageTool server, one request per piece from languagetool.extract, a few at a time

local extract = require("languagetool.extract")

local M = {}

M.ns = vim.api.nvim_create_namespace("languagetool")
-- One extmark per diagnostic, which follows the edits until the next check: vim.diagnostic.get keeps the old positions
M.marks = vim.api.nvim_create_namespace("languagetool.marks")
-- nf-md-spellcheck: the kind of the blink.cmp items, and the statusline mark of a paused buffer
M.icon = "󰓆"

local MAX_REQUESTS = 4

local queue, running = {}, 0
local generations = {}
-- Per buffer, the matches of the last check by language and piece: a write sends only the pieces it changed
local caches = {}
-- Per buffer, the fidget progress of the check under way
local progress = {}
-- Buffers whose automatic checks no longer pause, until Neovim exits
local resumed = {}
local warned = false

-- Overridden by vim.g.languagetool, read at each check
local DEFAULTS = {
  url = "http://localhost:8081",
  -- Automatic checks pause with more pieces than this to send, on battery or with this load per core
  pause_pieces = 100,
  pause_load = 1,
}

local function option(name)
  return (vim.g.languagetool or {})[name] or DEFAULTS[name]
end

M.languages = { "auto", "en-US", "fr" }

-- Out of the repositories, next to the trust file of vim.secure
local function settings_file()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "languagetool.json")
end

-- The settings of every file, lang and disabled, by real path: a file opened through a stow link keeps them
local function all_settings()
  local file = settings_file()
  return vim.fn.filereadable(file) == 1 and vim.json.decode(table.concat(vim.fn.readfile(file), "\n")) or {}
end

local function real_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and (vim.uv.fs_realpath(name) or name) or nil
end

local function file_settings(buf)
  return all_settings()[real_path(buf)] or {}
end

-- nil removes the setting
---@return boolean false after an error message
local function save(buf, name, value)
  local path = real_path(buf)
  if not path then
    vim.notify("languagetool: the buffer has no file to keep its settings", vim.log.levels.ERROR)
    return false
  end
  local settings = all_settings()
  settings[path] = settings[path] or {}
  settings[path][name] = value
  if vim.tbl_isempty(settings[path]) then
    settings[path] = nil
  end
  local file = settings_file()
  vim.fn.mkdir(vim.fs.dirname(file), "p")
  vim.fn.writefile({ vim.json.encode(settings) }, file)
  return true
end

--- The language forced on the buffer's file, nil when it is picked per piece
function M.forced_language(buf)
  return file_settings(buf).lang
end

--- Forces the language of the buffer's file in every session; auto goes back to picking it per piece
---@return boolean false after an error message
function M.set_language(buf, lang)
  if not vim.list_contains(M.languages, lang) then
    vim.notify(("languagetool: %s is none of %s"):format(lang, table.concat(M.languages, ", ")), vim.log.levels.ERROR)
    return false
  end
  return save(buf, "lang", lang ~= "auto" and lang or nil)
end

--- Whether the checks of the buffer's file are turned off
function M.disabled(buf)
  return file_settings(buf).disabled == true
end

--- Whether automatic checks should spare the machine: on battery, or above pause_load per core
function M.busy()
  if vim.uv.loadavg() >= option("pause_load") * vim.uv.available_parallelism() then
    return true
  end
  -- macOS; elsewhere, never on battery
  return vim.fn.executable("pmset") == 1
    and vim.system({ "pmset", "-g", "batt" }, { text = true }):wait().stdout:find("'Battery Power'", 1, true) ~= nil
end

-- vim.b.languagetool_paused and vim.b.languagetool_disabled, which the statusline shows
local function flag(buf, name, value)
  value = value or nil
  if vim.b[buf][name] ~= value then
    vim.b[buf][name] = value
    vim.cmd.redrawstatus()
  end
end

local function words(list)
  local set = {}
  for word in list:gmatch("%S+") do
    set[word] = true
  end
  return set
end

local FRENCH = words("le la les un une des du de et est ce cette ces pour dans sur pas que qui il elle ils avec au aux")
local ENGLISH = words("the is are an to of and in for that it this with not be by or from when if can should does")

-- Not language=auto: LanguageTool 6.8 reads a short French sentence as Italian, even with preferredLanguages=en,fr
local function language(segment)
  local score = 0
  for _, a in ipairs(segment.annotations) do
    if a.text then
      for word in a.text:lower():gmatch("%a+") do
        score = score + (FRENCH[word] and 1 or ENGLISH[word] and -1 or 0)
      end
      -- Accented Latin letters: é, è, à, ç…
      local _, accents = a.text:gsub("\195[\128-\191]", "")
      score = score + accents
    end
  end
  return score > 0 and "fr" or "en-US"
end

-- The words added with zg; 'spellfile' is empty until the first zg of the session
local function good_words()
  local files = vim.opt.spellfile:get()
  if #files == 0 then
    files = vim.api.nvim_get_runtime_file("spell/*.add", true)
  end
  local good = {}
  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      for _, line in ipairs(vim.fn.readfile(file)) do
        -- zug overwrites the first character with #, zw writes word/!
        local word, flags = line:match("^([^#/][^/]*)/?(.*)$")
        if word and not flags:find("!", 1, true) then
          good[word] = true
          -- As in Vim, a word also covers its all-caps form: GitLab covers GITLAB
          good[word:upper()] = true
        end
      end
    end
  end
  return good
end

local function run()
  while running < MAX_REQUESTS and #queue > 0 do
    local request = table.remove(queue, 1)
    if not request.stale() then
      running = running + 1
      vim.system(
        {
          "curl",
          "--silent",
          "--show-error",
          "--fail-with-body",
          "--max-time",
          "30",
          "--data-urlencode",
          "language=" .. request.language,
          "--data-urlencode",
          "data@-",
          option("url") .. "/v2/check",
        },
        { stdin = request.data, text = true },
        vim.schedule_wrap(function(result)
          running = running - 1
          request.done(result)
          run()
        end)
      )
    end
  end
end

-- LanguageTool counts offsets in UTF-16 code units (6.8), Neovim in bytes
local function byte(segment, offset)
  return vim.str_byteindex(segment.text, "utf-16", offset, false)
end

local function position(segment, b)
  local before = segment.text:sub(1, b)
  local _, lines = before:gsub("\n", "")
  if lines == 0 then
    return segment.row, segment.col + b
  end
  return segment.row + lines, b - before:match(".*()\n")
end

local function diagnostic(segment, match)
  local s = byte(segment, match.offset)
  local e = byte(segment, match.offset + match.length)
  local lnum, col = position(segment, s)
  local end_lnum, end_col = position(segment, e)
  return {
    lnum = lnum,
    col = col,
    end_lnum = end_lnum,
    end_col = end_col,
    severity = vim.diagnostic.severity.HINT,
    message = match.message,
    source = "languagetool",
    code = match.rule.id,
    user_data = {
      text = segment.text:sub(s + 1, e),
      replacements = vim
        .iter(match.replacements)
        :take(5)
        :map(function(r)
          return r.value
        end)
        :totable(),
    },
  }
end

-- The check under way, if any, drops its requests, so it never reaches its finish
local function drop(buf)
  generations[buf] = (generations[buf] or 0) + 1
  if progress[buf] then
    progress[buf]:finish()
    progress[buf] = nil
  end
  return generations[buf]
end

--- Replaces the diagnostics of buf once every piece is checked; a newer check drops the results of an older one
---@param opts? { force?: boolean } check even when M.busy() pauses the automatic checks
function M.check(buf, opts)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local settings = file_settings(buf)
  flag(buf, "languagetool_disabled", settings.disabled)
  if settings.disabled then
    drop(buf)
    flag(buf, "languagetool_paused", false)
    vim.diagnostic.reset(M.ns, buf)
    vim.api.nvim_buf_clear_namespace(buf, M.marks, 0, -1)
    return
  end
  local segments = extract.segments(buf)
  if not segments then
    return
  end

  -- Commits are in English, even when the guess per piece reads their words as French
  local forced = settings.lang or (vim.bo[buf].filetype == "gitcommit" and "en-US" or nil)
  local cache, used, diagnostics, todo = caches[buf] or {}, {}, {}, {}
  local good = good_words()

  local function add(segment, matches)
    for _, match in ipairs(matches) do
      local d = diagnostic(segment, match)
      local text = d.user_data.text
      -- A word added in lowercase also covers Dotfiles or DOTFILES, as in Vim
      if not (match.rule.issueType == "misspelling" and (good[text] or good[text:lower()])) then
        table.insert(diagnostics, d)
      end
    end
  end

  for _, segment in ipairs(segments) do
    local request = {
      segment = segment,
      language = forced or language(segment),
      data = vim.json.encode({ annotation = segment.annotations }),
    }
    request.key = request.language .. request.data
    if cache[request.key] then
      used[request.key] = cache[request.key]
      add(segment, cache[request.key])
    else
      table.insert(todo, request)
    end
  end

  if not (opts and opts.force) and not resumed[buf] and #todo > option("pause_pieces") and M.busy() then
    flag(buf, "languagetool_paused", true)
    return
  end
  flag(buf, "languagetool_paused", false)

  local generation = drop(buf)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local pending = #todo

  local function stale()
    return generations[buf] ~= generation or not vim.api.nvim_buf_is_valid(buf)
  end

  local function percentage()
    return 100 * (#todo - pending) / #todo
  end

  local function finish()
    if stale() then
      return
    end
    caches[buf] = used
    if progress[buf] then
      progress[buf]:finish()
      progress[buf] = nil
    end
    -- Positions computed on another text would point to the wrong words
    if vim.api.nvim_buf_get_changedtick(buf) == tick then
      vim.api.nvim_buf_clear_namespace(buf, M.marks, 0, -1)
      for _, d in ipairs(diagnostics) do
        d.user_data.mark = vim.api.nvim_buf_set_extmark(buf, M.marks, d.lnum, d.col, {
          end_row = d.end_lnum,
          end_col = d.end_col,
          invalidate = true,
        })
      end
      vim.diagnostic.set(M.ns, buf, diagnostics)
    end
  end

  if pending == 0 then
    return finish()
  end
  -- Only a check still running after 0.5 s shows in fidget, when it is installed
  vim.defer_fn(function()
    local ok, fidget = pcall(require, "fidget.progress")
    if ok and pending > 0 and not stale() then
      progress[buf] = fidget.handle.create({
        lsp_client = { name = "languagetool" },
        title = "Checking",
        message = vim.fs.basename(vim.api.nvim_buf_get_name(buf)),
        percentage = percentage(),
      })
    end
  end, 500)
  for _, request in ipairs(todo) do
    request.stale = stale
    request.done = function(result)
      local ok, response = pcall(vim.json.decode, result.stdout)
      if result.code ~= 0 or not ok then
        if not warned then
          warned = true
          vim.notify("languagetool: " .. result.stderr .. result.stdout, vim.log.levels.WARN)
        end
      else
        used[request.key] = response.matches
        add(request.segment, response.matches)
      end
      pending = pending - 1
      if progress[buf] and not stale() then
        progress[buf]:report({ percentage = percentage() })
      end
      if pending == 0 then
        finish()
      end
    end
    table.insert(queue, request)
  end
  run()
end

--- Turns the checks of the buffer's file off or on in every session, then clears or checks it
function M.set_enabled(buf, enabled)
  if save(buf, "disabled", not enabled or nil) then
    M.check(buf, { force = true })
  end
end

--- Stops pausing the automatic checks of buf until Neovim exits, and checks it
function M.resume(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  resumed[buf] = true
  M.check(buf)
end

return M
