-- Checks comments, Markdown and commits with a LanguageTool server on open and on write, see lua/languagetool/init.lua

local group = vim.api.nvim_create_augroup("languagetool", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  callback = function(args)
    -- Scheduled: filetype detection, which picks the parser, may run after this autocmd
    vim.schedule(function()
      require("languagetool").check(args.buf)
    end)
  end,
})

local SUBCOMMANDS = { "disable", "enable", "lang", "resume" }

vim.api.nvim_create_user_command("LanguageTool", function(args)
  local languagetool = require("languagetool")
  local subcommand, value = args.fargs[1], args.fargs[2]
  if subcommand == nil and languagetool.disabled(0) then
    vim.notify("languagetool: disabled for this file, :LanguageTool enable", vim.log.levels.WARN)
  elseif subcommand == nil then
    languagetool.check(0, { force = true })
  elseif subcommand == "disable" or subcommand == "enable" then
    languagetool.set_enabled(0, subcommand == "enable")
  elseif subcommand == "resume" then
    languagetool.resume(0)
  elseif subcommand == "lang" and value == nil then
    local forced = languagetool.forced_language(0)
    vim.notify("languagetool: " .. (forced and forced .. ", forced for this file" or "auto"))
  elseif subcommand == "lang" then
    if languagetool.set_language(0, value) then
      languagetool.check(0, { force = true })
    end
  else
    vim.notify(
      ("languagetool: %s is none of %s"):format(subcommand, table.concat(SUBCOMMANDS, ", ")),
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = "*",
  complete = function(arglead, line)
    -- The words before the one being completed
    local words = vim.split(line:sub(1, -#arglead - 1), "%s+", { trimempty = true })
    local candidates = #words == 1 and SUBCOMMANDS
      or (#words == 2 and words[2] == "lang" and require("languagetool").languages)
      or {}
    return vim.tbl_filter(function(candidate)
      return vim.startswith(candidate, arglead)
    end, candidates)
  end,
  desc = "Check the buffer with LanguageTool, even when paused; subcommands: disable, enable, lang, resume",
})
