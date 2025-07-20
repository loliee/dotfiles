return {
  "echasnovski/mini.statusline",
  lazy = false,
  config = function()
    local statusline = require("mini.statusline")
    statusline.setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
      use_icons = vim.g.have_nerd_font,
      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
          local git = statusline.section_git({ trunc_width = 40 })
          local diff = statusline.section_diff({ trunc_width = 75 })
          local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
          local lsp = statusline.section_lsp({ trunc_width = 75 })
          local filename = statusline.section_filename({ trunc_width = 140 })
          local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
          local location = statusline.section_location({ trunc_width = 75 })
          local search = statusline.section_searchcount({ trunc_width = 75 })
          local copilot_hl = "MiniStatusLineCopilotDisabled"

          if package.loaded["copilot"] then
            local client = vim.lsp.get_clients({ name = "copilot", bufnr = vim.api.nvim_get_current_buf() })
            local ft = vim.bo.filetype
            if #client > 0 or ft == "copilot-chat" then
              copilot_hl = "MiniStatusLineCopilotEnabled"
            end
          end

          return statusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
            { hl = copilot_hl, strings = { vim.g.copilot_icon } },
            "%<", -- Mark general truncate point
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=", -- End left alignment
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
        end,

        diagnostic_levels = {
          { name = "ERROR", sign = "✗" },
          { name = "WARN", sign = "" },
          { name = "INFO", sign = "" },
          { name = "HINT", sign = "" },
        },
      },
      inactive = nil, -- Keeps the default inactive statusline
    })
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return "%2l:%-2v"
    end
  end,
}
