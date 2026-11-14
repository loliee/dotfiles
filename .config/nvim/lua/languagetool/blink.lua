-- blink.cmp source: the LanguageTool replacements for the diagnostic under the cursor

local languagetool = require("languagetool")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

local function not_after(row, col, other_row, other_col)
  return row < other_row or (row == other_row and col <= other_col)
end

-- Where the flagged text is now, after the edits made since the check; nil once it is deleted
local function position(bufnr, d)
  local mark = vim.api.nvim_buf_get_extmark_by_id(bufnr, languagetool.marks, d.user_data.mark, { details = true })
  if #mark == 0 or mark[3].invalid then
    return nil
  end
  return { lnum = mark[1], col = mark[2], end_lnum = mark[3].end_row, end_col = mark[3].end_col }
end

local function flagged(bufnr, p)
  local ok, text = pcall(vim.api.nvim_buf_get_text, bufnr, p.lnum, p.col, p.end_lnum, p.end_col, {})
  return ok and table.concat(text, "\n") or nil
end

function source.get_completions(_, ctx, callback)
  local row, col = ctx.cursor[1] - 1, ctx.cursor[2]
  local items = {}
  for _, d in ipairs(vim.diagnostic.get(ctx.bufnr, { namespace = languagetool.ns })) do
    local p = position(ctx.bufnr, d)
    local under = p and not_after(p.lnum, p.col, row, col) and not_after(row, col, p.end_lnum, p.end_col)
    -- Only while the range still holds the flagged text: an edit inside it moves no extmark
    if under and flagged(ctx.bufnr, p) == d.user_data.text then
      local range =
        { start = { line = p.lnum, character = p.col }, ["end"] = { line = p.end_lnum, character = p.end_col } }
      for i, replacement in ipairs(d.user_data.replacements) do
        table.insert(items, {
          label = replacement,
          kind = vim.lsp.protocol.CompletionItemKind.Text,
          kind_icon = languagetool.icon,
          -- The flagged text, which the keyword under the cursor always matches
          filterText = d.user_data.text,
          sortText = ("%02d"):format(i),
          documentation = d.message,
          textEdit = { newText = replacement, range = range },
        })
      end
    end
  end
  callback({ items = items, is_incomplete_backward = false, is_incomplete_forward = false })
end

return source
