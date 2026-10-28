-- Only in trusted projects: the file's own, and the cwd where the linter finds node_modules/.bin and its config
local function trusted(ctx)
  local security = require("security")
  return security.trusted(ctx.filename) and security.trusted(vim.fn.getcwd())
end

-- Linters turned off per file by :Lint disable, by real path; out of the repositories, like vim.secure's trust file
local state = vim.fs.joinpath(vim.fn.stdpath("state"), "lint.json")

local function disabled_linters()
  return vim.fn.filereadable(state) == 1 and vim.json.decode(table.concat(vim.fn.readfile(state), "\n")) or {}
end

local function real_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and (vim.uv.fs_realpath(name) or name) or nil
end

return {
  -- Cf. https://www.lazyvim.org/plugins/linting
  "mfussenegger/nvim-lint",
  event = { "VeryLazy" },
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      fish = { "fish" },
      lua = { "luacheck" },
      markdown = { "mdl" },
      python = { "ruff", "bandit" },
      javascript = { "eslint" },
      sh = { "shellcheck" },
      yaml = { "yamllint" },
      dockerfile = { "hadolint" },
      go = { "golangcilint" },
      json = { "jq" },
      terraform = { "tflint", "trivy" },
      -- Use the "*" filetype to run linters on all filetypes.
      ["*"] = { "codespell" },
      -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
      -- ['_'] = { 'fallback linter' },
    },
    -- Add custom linters.
    ---@type table<string,table>
    linters = {
      tflint = {
        -- Runs the plugins .tflint.hcl names, from ./.tflint.d/plugins
        condition = trusted,
        prepend_args = { "--max-workers=" .. math.max(1, math.floor(#vim.loop.cpu_info() / 2)) },
      },
      -- .luacheckrc is Lua, run with the global environment
      luacheck = { condition = trusted },
      -- eslint.config.js is JavaScript
      eslint = { condition = trusted },
      -- .golangci.yml can load Go plugins
      golangcilint = { condition = trusted },
      -- LanguageTool checks Markdown prose and commits: codespell would report the same typos twice
      codespell = {
        -- The words added with `zg`, as the prek hook reads them
        prepend_args = { "--ignore-words=" .. vim.o.spellfile },
        condition = function()
          return vim.bo.filetype ~= "markdown" and vim.bo.filetype ~= "gitcommit"
        end,
      },
      mdl = {
        -- .mdlrc can point to a style file, which is Ruby
        condition = trusted,
        cmd = "mdl",
        stdin = false,
        args = {},
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          for line in vim.gsplit(output, "\n") do
            local f, lnum, msg = string.match(line, "^([^:]+):(%d+):%s(.+)")
            if f and lnum and msg then
              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = 0,
                end_lnum = tonumber(lnum),
                end_col = 0,
                source = "mdl",
                message = msg,
                severity = vim.diagnostic.severity.ERR,
              })
            end
          end
          return diagnostics
        end,
      },
      languagetool = {
        cmd = "languagetool-code",
        args = {},
        stdin = true,
        parser = function(output, bufnr)
          local decoded = vim.json.decode(output)
          local diagnostics = {}
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
          local content = table.concat(lines, "\n")
          for _, match in pairs(decoded.matches or {}) do
            local byteidx = vim.fn.byteidx(content, match.offset)
            local line = vim.fn.byte2line(byteidx)
            local col = byteidx - vim.fn.line2byte(line)
            table.insert(diagnostics, {
              lnum = line - 1,
              end_lnum = line - 1,
              col = col + 1,
              end_col = col + 1,
              message = match.message,
            })
          end
          return diagnostics
        end,
      },
    },
  },
  config = function(_, opts)
    local M = {}

    local lint = require("lint")
    for name, linter in pairs(opts.linters) do
      if type(linter) == "table" and type(lint.linters[name]) == "table" then
        lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        if type(linter.prepend_args) == "table" then
          lint.linters[name].args = lint.linters[name].args or {}
          vim.list_extend(lint.linters[name].args, linter.prepend_args)
        end
      else
        lint.linters[name] = linter
      end
    end

    lint.linters_by_ft = opts.linters_by_ft

    function M.debounce(ms, fn)
      local timer = vim.uv.new_timer()
      return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
          timer:stop()
          vim.schedule_wrap(fn)(unpack(argv))
        end)
      end
    end

    -- nvim-lint signals no end of linter: fidget follows get_running, polled as in the statusline example of its README
    local progress, poll = {}, vim.uv.new_timer()
    function M.progress()
      local running = {}
      for _, name in ipairs(lint.get_running()) do
        running[name] = true
        progress[name] = progress[name]
          or require("fidget.progress").handle.create({ lsp_client = { name = "nvim-lint" }, title = name })
      end
      for name, handle in pairs(progress) do
        if not running[name] then
          handle:finish()
          progress[name] = nil
        end
      end
      if not next(progress) then
        poll:stop()
      end
    end

    function M.linters()
      -- Use nvim-lint's logic first:
      -- * checks if linters exist for the full filetype first
      -- * otherwise will split filetype by "." and add all those linters
      -- * this differs from conform.nvim which only uses the first filetype that has a formatter
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)

      -- Create a copy of the names table to avoid modifying the original.
      names = vim.list_extend({}, names)

      -- Add fallback linters.
      if #names == 0 then
        vim.list_extend(names, lint.linters_by_ft["_"] or {})
      end

      -- Add global linters.
      vim.list_extend(names, lint.linters_by_ft["*"] or {})

      -- Filter out linters that don't exist or don't match the condition.
      local ctx = { filename = vim.api.nvim_buf_get_name(0) }
      ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        if not linter then
          ---@diagnostic disable-next-line
          error("Linter not found: " .. name, { title = "nvim-lint" })
        end
        ---@diagnostic disable-next-line
        return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
      end, names)
      return names
    end

    function M.disabled()
      local path = real_path(0)
      return path and disabled_linters()[path] or {}
    end

    function M.lint()
      local disabled = M.disabled()
      local names = vim.tbl_filter(function(name)
        return not vim.list_contains(disabled, name)
      end, M.linters())

      -- Run linters.
      if #names > 0 then
        lint.try_lint(names)
        -- Only the linters still running after 0.5 s: the fast ones would flash at every InsertLeave
        poll:start(500, 200, vim.schedule_wrap(M.progress))
      end
    end

    -- Kept across sessions; disabling also clears what the linter reported on the buffer
    function M.set_enabled(name, enabled)
      local path = real_path(0)
      if not path then
        vim.notify("nvim-lint: the buffer has no file to keep its linters", vim.log.levels.ERROR)
        return
      end
      local all = disabled_linters()
      local names = vim.tbl_filter(function(other)
        return other ~= name
      end, all[path] or {})
      if not enabled then
        table.insert(names, name)
      end
      all[path] = #names > 0 and names or nil
      vim.fn.mkdir(vim.fs.dirname(state), "p")
      vim.fn.writefile({ vim.json.encode(all) }, state)
      if enabled then
        M.lint()
      else
        vim.diagnostic.reset(lint.get_namespace(name), 0)
      end
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = M.debounce(100, M.lint),
    })

    vim.api.nvim_create_user_command("Lint", function(args)
      local action, name = args.fargs[1], args.fargs[2]
      local linters = M.linters()
      if action == nil then
        local disabled = M.disabled()
        local list = vim.tbl_map(function(linter)
          return vim.list_contains(disabled, linter) and linter .. " (disabled)" or linter
        end, linters)
        vim.notify("nvim-lint: " .. (#list > 0 and table.concat(list, ", ") or "no linter"))
      elseif (action == "disable" or action == "enable") and vim.list_contains(linters, name) then
        M.set_enabled(name, action == "enable")
      else
        local message = "nvim-lint: disable or enable one of " .. table.concat(linters, ", ")
        vim.notify(message, vim.log.levels.ERROR)
      end
    end, {
      nargs = "*",
      complete = function(arglead, line)
        -- The words before the one being completed
        local words = vim.split(line:sub(1, -#arglead - 1), "%s+", { trimempty = true })
        local candidates = #words == 1 and { "disable", "enable" } or #words == 2 and M.linters() or {}
        return vim.tbl_filter(function(candidate)
          return vim.startswith(candidate, arglead)
        end, candidates)
      end,
      desc = "List the linters of the buffer, or disable or enable one for its file",
    })
  end,
}
