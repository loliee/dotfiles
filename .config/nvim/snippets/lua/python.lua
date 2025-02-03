-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta

local function isempty(s) --util
  return s == nil or s == ""
end

local get_visual = function(args, parent, _, user_args) -- third argument is old_state, which we don't use
  local ret
  if isempty(user_args) then
    ret = "" -- edit if needed
  else
    ret = user_args
  end
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1, ret))
  end
end

return {
  s({ -- Shebang
    trig = "#!",
    desc = "Add python shebang.",
  }, {
    t({ "#!/usr/bin/env python", "" }),
  }),

  s( -- for
    {
      trig = "for",
      desc = "Add for loop.",
    },
    fmta(
      [[
            for <> in <>:
                <>

            ]],
      {
        i(1),
        i(2),
        d(3, get_visual, {}, { user_args = { "pass" } }),
      }
    )
  ),
}
