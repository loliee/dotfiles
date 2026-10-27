-- Cuts a buffer into the pieces LanguageTool checks: comments in code, prose in Markdown, the message of a commit.
-- Each piece is the exact text of the buffer from row, col, split into text and markup annotations, so LanguageTool's
-- offsets point into it

local M = {}

local LEAD = "^([ \t]*[%-#/;%*!%%<{%[=]*[ \t]*)(.*)$"
local CLOSERS = { "[ \t]*%*+/[ \t]*$", "[ \t]*%]=*%][ \t]*$", "[ \t]*%-%->[ \t]*$", "[ \t]*#}[ \t]*$" }

local INLINE = [[
(code_span) @code
[(uri_autolink) (email_autolink)] @code
(backslash_escape) @escape
[(emphasis_delimiter) (link_destination) (link_title) (link_label) (html_tag) (entity_reference)] @markup
(inline_link ["[" "]" "(" ")"] @markup)
(image ["!" "[" "]" "(" ")"] @markup)
(full_reference_link ["[" "]"] @markup)
(collapsed_reference_link ["[" "]"] @markup)
(shortcut_link ["[" "]"] @markup)
]]

local BLOCKS = [[
[(paragraph) (atx_heading) (setext_heading) (pipe_table)] @block
[(inline) (pipe_table_cell)] @text
]]

local function push(list, kind, str, interpret)
  if str ~= "" then
    table.insert(list, kind == "text" and { text = str } or { markup = str, interpretAs = interpret })
  end
end

local function bytes(node)
  return select(3, node:start()), select(3, node:end_())
end

-- Sorted by start, a node inside an earlier one dropped: a comment captured twice, a paragraph in a setext heading
local function outermost(nodes)
  table.sort(nodes, function(a, b)
    local as, ae = bytes(a)
    local bs, be = bytes(b)
    return as < bs or (as == bs and ae > be)
  end)
  local kept, last = {}, -1
  for _, node in ipairs(nodes) do
    local s, e = bytes(node)
    if s >= last then
      table.insert(kept, node)
      last = e
    end
  end
  return kept
end

local function looks_like_code(word)
  return word:find("[_/\\=<>{}%[%]()@#$|~*`]")
    or word:find("%w%.%w")
    or word:find("%l%u")
    or word:find("^%-%-?%w")
    or word:find("::", 1, true)
end

-- Inline code and words that look like code are read as X: LanguageTool would flag them, and an empty
-- interpretAs leaves holes in the sentence ("dans `src/`" read as "dans")
local function words(list, content)
  local spans = {}
  for s, e in content:gmatch("()`[^`]+`()") do
    table.insert(spans, { s, e })
  end
  local found = {}
  for s, word in content:gmatch("()(%S+)") do
    local e = s + #word
    local in_span = vim.iter(spans):any(function(span)
      return s < span[2] and e > span[1]
    end)
    if not in_span then
      local lead = word:match("^[%(%[\"']*")
      -- Not ! or ?: in a word that looks like code, they are part of it, as in #offset!
      local trail = word:sub(#lead + 1):match("[,;:.\"']*$")
      local core = word:sub(#lead + 1, #word - #trail)
      -- A closing bracket belongs to the sentence, unless the word opened it: (see foo) but foo(x)
      while core:find("[%)%]]$") and not core:find(core:sub(-1) == ")" and "(" or "[", 1, true) do
        core = core:sub(1, -2)
      end
      if core ~= "" and looks_like_code(core) then
        table.insert(found, { s + #lead, s + #lead + #core })
      end
    end
  end
  vim.list_extend(spans, found)
  table.sort(spans, function(a, b)
    return a[1] < b[1]
  end)
  local pos = 1
  for _, span in ipairs(spans) do
    push(list, "text", content:sub(pos, span[1] - 1))
    push(list, "markup", content:sub(span[1], span[2] - 1), "X")
    pos = span[2]
  end
  push(list, "text", content:sub(pos))
end

local function comment_annotations(text)
  local list, prose = {}, false
  for i, line in ipairs(vim.split(text, "\n", { plain = true })) do
    local lead, content = line:match(LEAD)
    local close = ""
    for _, pattern in ipairs(CLOSERS) do
      local s = content:find(pattern)
      if s then
        content, close = content:sub(1, s - 1), content:sub(s)
        break
      end
    end
    local trailing = content:match("[ \t]*$")
    content = content:sub(1, #content - #trailing)
    -- An annotation line, ---@param or ytt's #@, is code
    local has_text = content ~= "" and content:sub(1, 1) ~= "@"
    -- A line break between two lines of prose is read as a space, or LanguageTool glues the words
    push(list, "markup", (i > 1 and "\n" or "") .. lead, (has_text and prose) and " " or nil)
    if has_text then
      words(list, content)
      prose = true
    else
      push(list, "markup", content)
    end
    push(list, "markup", trailing .. close)
  end
  return list
end

local function comments(parser, buf, src)
  local nodes = {}
  parser:for_each_tree(function(tree, ltree)
    local query = vim.treesitter.query.get(ltree:lang(), "highlights")
    if not query then
      return
    end
    for id, node in query:iter_captures(tree:root(), buf) do
      local name = query.captures[id]
      if name == "comment" or vim.startswith(name, "comment.") then
        table.insert(nodes, node)
      end
    end
  end)

  -- Line comments that follow each other at the same column make one piece, so sentences can span lines
  local groups, current = {}, nil
  for _, node in ipairs(outermost(nodes)) do
    local sr, sc, sb, er, ec, eb = node:range(true)
    if not (sb == 0 and src:sub(1, 2) == "#!") then
      local gap = current and src:sub(current.eb + 1, sb)
      if current and sc == current.col and sr == current.next_row and gap:match("^[ \t]*\n?[ \t]*$") then
        current.eb = eb
      else
        current = { row = sr, col = sc, sb = sb, eb = eb }
        table.insert(groups, current)
      end
      current.next_row = ec == 0 and er or er + 1
    end
  end

  return vim.tbl_map(function(group)
    local text = src:sub(group.sb + 1, group.eb)
    return { row = group.row, col = group.col, text = text, annotations = comment_annotations(text) }
  end, groups)
end

local function markdown(parser, buf, src)
  local query = vim.treesitter.query.parse("markdown", BLOCKS)
  local blocks, texts = {}, {}
  for id, node in query:iter_captures(parser:trees()[1]:root(), buf) do
    if query.captures[id] == "block" then
      table.insert(blocks, node)
    else
      -- The > and indentation of a paragraph in a quote or a list are its children
      local s = bytes(node)
      for child in node:iter_children() do
        if child:named() then
          local cs, ce = bytes(child)
          table.insert(texts, { s, cs })
          s = ce
        end
      end
      table.insert(texts, { s, select(2, bytes(node)) })
    end
  end
  table.sort(texts, function(a, b)
    return a[1] < b[1]
  end)
  -- The padding of table cells is markup, or LanguageTool flags the repeated spaces
  for _, t in ipairs(texts) do
    while t[1] < t[2] and src:sub(t[1] + 1, t[1] + 1):match("[ \t]") do
      t[1] = t[1] + 1
    end
    while t[2] > t[1] and src:sub(t[2], t[2]):match("[ \t]") do
      t[2] = t[2] - 1
    end
  end

  local marks = {}
  local inline = vim.treesitter.query.parse("markdown_inline", INLINE)
  parser:for_each_tree(function(tree, ltree)
    if ltree:lang() ~= "markdown_inline" then
      return
    end
    for id, node in inline:iter_captures(tree:root(), buf) do
      local kind = inline.captures[id]
      local s, e = bytes(node)
      table.insert(marks, { s, e, kind == "code" and "X" or kind == "escape" and src:sub(e, e) or nil })
    end
  end)
  table.sort(marks, function(a, b)
    return a[1] < b[1]
  end)

  local segments = {}
  for _, block in ipairs(outermost(blocks)) do
    local row, col = block:start()
    local bs, be = bytes(block)
    local list, pos = {}, bs
    -- Block structure between texts: heading and list markers, and table pipes, read as a paragraph break per cell
    local function structure(to)
      local str = src:sub(pos + 1, to)
      push(list, "markup", str, str:find("|", 1, true) and "\n\n" or nil)
      pos = to
    end
    for _, t in ipairs(texts) do
      if t[1] >= pos and t[2] <= be then
        structure(t[1])
        for _, m in ipairs(marks) do
          if m[1] >= pos and m[2] <= t[2] then
            push(list, "text", src:sub(pos + 1, m[1]))
            push(list, "markup", src:sub(m[1] + 1, m[2]), m[3])
            pos = m[2]
          end
        end
        push(list, "text", src:sub(pos + 1, t[2]))
        pos = t[2]
      end
    end
    structure(be)
    table.insert(segments, { row = row, col = col, text = src:sub(bs + 1, be), annotations = list })
  end
  return segments
end

-- Line by line, not with the gitcommit parser: it reads the ' of core.commentChar in .gitconfig as message text
local function commit(src)
  local segments, current, row = {}, nil, 0
  for line in src:gmatch("([^\n]*)\n") do
    -- The diff of commit -v, which git drops
    if line:find("^' %-+ >8 %-+$") then
      break
    end
    if line:find("^'") or not line:find("%S") then
      current = nil
    elseif current then
      current.text = current.text .. "\n" .. line
    else
      current = { row = row, col = 0, text = line }
      table.insert(segments, current)
    end
    row = row + 1
  end
  for _, segment in ipairs(segments) do
    segment.annotations = comment_annotations(segment.text)
  end
  return segments
end

--- The pieces of buf to check, nil when no parser reads it
function M.segments(buf)
  local parser = vim.treesitter.get_parser(buf, nil, { error = false })
  if not parser then
    return nil
  end
  parser:parse(true)
  local src = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, true), "\n") .. "\n"
  if parser:lang() == "gitcommit" then
    return commit(src)
  end
  if parser:lang() == "markdown" then
    return markdown(parser, buf, src)
  end
  return comments(parser, buf, src)
end

return M
