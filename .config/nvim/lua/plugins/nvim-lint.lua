return { --
  -- Cf. https://www.lazyvim.org/plugins/linting
  "mfussenegger/nvim-lint",
  event = { "VeryLazy" },
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      fish = { "fish" },
      lua = { "luacheck" },
      -- markdown = { "codespell" },
      python = { "flake8", "bandit" },
      javascript = { "eslint" },
      sh = { "shellcheck" },
      yaml = { "yamllint" },
      dockerfile = { "hadolint" },
      go = { "golangcilint" },
      json = { "jq" },
      terraform = { "tflint", "tfsec" },
      -- Use the "*" filetype to run linters on all filetypes.
      ["*"] = { "codespell" },
      -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
      -- ['_'] = { 'fallback linter' },
      -- ["*"] = { "typos" },
    },
    -- LazyVim extension to easily override linter options
    -- or add custom linters.
    ---@type table<string,table>
    linters = {
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

    function M.lint()
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

      -- Run linters.
      if #names > 0 then
        lint.try_lint(names)
      end
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = M.debounce(100, M.lint),
    })
  end,
}
