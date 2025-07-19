-- Cf. https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
-- https://www.w3schools.com/colors/colors_picker.asp
-- :Telescope highlights

local M = function(h, c)
  h.Visual = { bg = c.comment, fg = c.yellow }
  h.ErrorMsg = {
    bg = c.bg_dark,
    fg = c.red,
  }
  h.Identifier = {
    fg = c.yellow,
  }
  h.Constant = {
    fg = c.magenta,
  }
  h["@constructor"] = {
    fg = c.yellow,
  }
  h["@keyword"] = {
    fg = c.yellow,
  }
  h.Function = {
    fg = c.blue_bright,
  }
  h.Italic = {
    fg = c.blue,
  }
  h.String = {
    fg = c.green_bright,
  }
  h.Debug = {
    fg = c.yellow,
  }
  h["@comment.error"] = {
    fg = c.red,
  }
  h["@comment.hint"] = {
    fg = c.yellow,
  }
  h["@comment.note"] = {
    fg = c.blue,
  }
  h["@comment.todo"] = {
    fg = c.comment,
  }
  h["@comment.warning"] = {
    fg = c.comment,
  }
  h.DiagnosticError = {
    fg = c.red,
  }
  h.DiagnosticHint = {
    fg = c.fg,
  }
  h.DiagnosticInfo = {
    fg = c.blue_bright,
  }
  h.DiagnosticUnderlineError = {
    sp = "#db4b4b",
    undercurl = true,
  }
  h.DiagnosticUnderlineHint = {
    sp = "#1abc9c",
    undercurl = true,
  }
  h.DiagnosticUnderlineInfo = {
    sp = "#0db9d7",
    undercurl = true,
  }
  h.DiagnosticUnderlineWarn = {
    sp = "#e0af68",
    undercurl = true,
  }
  h.DiagnosticUnnecessary = {
    fg = c.yellow,
  }
  h.DiagnosticVirtualTextError = {
    bg = c.bg_dark,
    fg = c.red,
  }
  h.DiagnosticVirtualTextHint = {
    bg = c.bg_dark,
    fg = c.green,
  }
  h.DiagnosticVirtualTextInfo = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.DiagnosticVirtualTextWarn = {
    bg = c.bg_dark,
    fg = c.yellow,
  }
  h.DiagnosticWarn = {
    fg = c.yellow,
  }
  h.StatusLine = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.StatusLineNC = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.TabLine = {
    bg = c.bg_dark,
    fg = c.comment,
  }
  h.MiniStatuslineInactive = {
    bg = c.bg_dark,
    fg = c.comment,
  }
  h.MiniStatuslineDevinfo = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.MiniStatuslineFileinfo = {
    bg = c.bg_dark,
    fg = c.fg,
    bold = true,
  }
  h.MiniStatuslineFilename = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.MiniStatuslineModeCommand = {
    bg = c.bg_dark,
    fg = c.blue,
    bold = true,
  }
  h.MiniStatuslineModeInsert = {
    bg = c.bg_dark,
    fg = c.yellow,
    bold = true,
  }
  h.MiniStatuslineModeNormal = {
    bg = c.bg_dark,
    fg = c.green,
    bold = true,
  }
  h.MiniStatuslineModeVisual = {
    bg = c.bg_dark,
    fg = c.pink,
    bold = true,
  }
  h.MiniStatuslineModeOther = {
    bold = true,
  }
  h.MiniStatuslineModeReplace = {
    bg = c.bg_dark,
    fg = c.fg,
    bold = true,
  }
  h.MiniStatusLineCopilotEnabled = {
    fg = c.red,
  }
  h.MiniStatusLineCopilotDisabled = {
    fg = c.comment,
  }
  h.TabLineFill = {
    bg = c.bg_dark,
  }
  h.diffAdded = {
    fg = c.green,
  }
  h.diffChanged = {
    fg = c.yellow,
  }
  h.diffFile = {
    fg = c.blue,
  }
  h.diffIndexLine = {
    fg = c.blue,
  }
  h.diffLine = {
    fg = c.orange,
  }
  h.diffNewFile = {
    fg = c.yellow,
  }
  h.diffOldFile = {
    fg = c.yellow,
  }
  h.diffRemoved = {
    fg = c.magenta,
  }
  h.GitGutterAdd = {
    fg = c.green,
  }
  h.GitGutterAddLineNr = {
    fg = c.green,
  }
  h.GitGutterChange = {
    fg = c.yellow,
  }
  h.GitGutterChangeLineNr = {
    fg = c.yellow,
  }
  h.GitGutterDelete = {
    fg = c.magenta,
  }
  h.GitGutterDeleteLineNr = {
    fg = c.magenta,
  }
  h.GitSignsAdd = {
    fg = c.green,
  }
  h.GitSignsChange = {
    fg = c.yellow,
  }
  h.GitSignsDelete = {
    fg = c.red,
  }
  h.GitSignsBlameColor = {
    fg = c.magenta,
  }
  h.TelescopeNormal = {
    bg = c.bg_dark,
    fg = c.fg_dark,
  }
  h.TelescopeBorder = {
    bg = c.bg_dark,
    fg = c.bg_dark,
  }
  h.TelescopePromptNormal = {
    bg = c.black,
  }
  h.TelescopePromptBorder = {
    bg = c.black,
    fg = c.black,
  }
  h.TelescopePromptTitle = {
    bg = c.bg_dark,
    fg = c.fg,
    bold = true,
  }
  h.TelescopePreviewTitle = {
    bg = c.bg_dark,
    fg = c.green,
  }
  h.TelescopeResultsTitle = {
    bg = c.bg_dark,
    fg = c.green,
  }
  h.TelescopeBorder = {
    bg = c.bg_dark,
    fg = c.terminal.black_bright,
  }
  h.TelescopeNormal = {
    bg = c.bg_dark,
    fg = c.fg,
  }
  h.TelescopePromptBorder = {
    bg = c.bg_dark,
    fg = c.yellow,
  }
  h.TelescopePromptTitle = {
    bg = c.bg_dark,
    fg = c.yellow,
    bold = true,
  }
  h.TelescopeResultsComment = {
    fg = "#545c7e",
  }
  h.CodeCompanionChatSeparator = {
    fg = c.green,
  }
  h.GrugFarHelpHeader = {
    fg = c.comment,
  }
  h.GrugFarResultsAddIndicator = {
    fg = c.green,
  }
  h.GrugFarResultsRemoveIndicator = {
    fg = c.magenta,
  }
  h.GrugFarHelpHeaderKey = {
    fg = c.blue_bright,
  }
  h.GrugFarInputLabel = {
    fg = c.blue,
  }
  h.GrugFarInputPlaceholder = {
    fg = c.comment,
  }
  h.GrugFarMatch = {
    fg = c.yellow,
    bg = c.comment,
  }
  h.GrugFarResultsHeader = {
    fg = c.yellow,
  }
  h.GrugFarResultsLineColumn = {
    fg = c.yellow,
  }
  h.GrugFarResultsStats = {
    fg = c.blue,
  }
end

return M
