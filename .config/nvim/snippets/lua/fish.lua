-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

return {
  s({ -- Shebang
    trig = "#!",
    desc = "Add fish shebang.",
  }, {
    t("#!/usr/bin/env fish"),
  }),

  s( -- Echo
    {
      trig = "echo >&2",
      desc = "Print message on stderr.",
    },
    fmta(
      [[
        echo >&2 "{}"

        ]],
      { i(1, { "[string]" }) },
      { delimiters = "{}" }
    )
  ),

  s( -- Cat
    {
      trig = "cat <<EOT",
      desc = "Write multi-string to file.",
    },
    fmta(
      [[
            cat <<EOT >>{}
            {}
            EOT

            ]],
      { i(1, { "[file]" }), i(2, { "[content]" }) },
      { delimiters = "{}" }
    )
  ),
}
