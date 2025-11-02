-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

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
        i(3),
      }
    )
  ),
}
